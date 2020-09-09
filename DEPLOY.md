# Deployment Process

There is nothing terribly special about an Imagine-enabled app as long as you choose to
use a single database.

This is but one of many ways to deploy an Elixir app. If you have more than a few, I'd recommend using
something like [Puppet](https://puppet.com/) to automate the web server and passenger steps.

The final outcome of this process is a git remote (repo) on a Linux server you have ssh access to.
Any time you want to deploy, you just commit your changes, then do a `git push production`
(or whatever you named your remote) and the deploy process will begin, ending with a seamless
restart (with a pause of a few seconds while the BEAM starts up, but no dropped client connections).

I recommend precompiling the assets locally (`npm run deploy`) and committing those to your repo
before each deploy. It saves time and server resources (at the cost of inflating your repo a little).
(For other Elixir apps, it would mean you don't need node/npm on the server, but Imagine still needs
node installed to use Handlebars.)

## App Changes

Passenger supplies a port number via the PORT environment variable which your app needs to bind on. However,
out of the box, Phoenix apps don't read the PORT env var at runtime. So you'll need to add this to your
endpoint (end of the file is fine):

```elixir
  @doc """
  Callback invoked for dynamically configuring the endpoint.

  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  def init(_key, config) do
    if config[:get_port_from_system_env] do
      port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      {:ok, config}
    end
  end
```

Then enable that option in your prod endpoint config:
```elixir
config :your_app, MykboWeb.Endpoint,
  get_port_from_system_env: true,
  server: true,
  ...
```

## Web Server

Anything that can reverse proxy to a tcp port will work. My current favorite is [Caddy](https://caddyserver.com/).

## Passenger Standalone

Sure, you could proxy directly to Cowboy, but [Passenger](https://www.phusionpassenger.com/docs/advanced_guides/gls/)
makes deployment and updates easier by (among many other things) queuing connections until your app is ready to
accept connections.

Here is an example Passengerfile.json tuned for Phoenix:
```
{
  "engine": "builtin",
  "environment": "production",
  "app_start_command": "/usr/bin/env PORT=$PORT ./bin/[your_app] start",
  "instance_registry_dir": "/home/[your_app]/sites/[your_app]/tmp",
  "port": 4004,
  "user": "[your_user]",
  "pid_file": "/home/[your_app]/sites/[your_app]/passenger.pid",
  "log_level": 2,
  "load_shell_envvars": true,
  "min_instances": 1,
  "max_pool_size": 1,
  "pool_idle_time": 0,
  "max_requests": 0,
  "turbocaching": false
}
```

And a unit file to start Passenger via systemd:
```
[Unit]
Description=Phusion Passenger Standalone for [your_app]
After=syslog.target network.target

[Service]
Type=simple
User=[your_user]
WorkingDirectory=/home/[your_app]/sites/[your_app]
Environment="BASH_ENV=/home/[your_app]/.bash_profile"
ExecStart=/bin/bash -l -c '/usr/local/bin/passenger start'
ExecStartPre=/bin/bash -c 'mkdir -p /home/[your_app]/sites/[your_app]/tmp'
Restart=always
RestartSec=15
SuccessExitStatus=3 4
RestartForceExitStatus=3 4

# Hardening
NoNewPrivileges=yes
PrivateTmp=yes
PrivateDevices=yes
DevicePolicy=closed
ProtectSystem=full
ProtectControlGroups=yes
ProtectKernelModules=yes
ProtectKernelTunables=yes
RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6 AF_NETLINK
RestrictRealtime=yes
RestrictNamespaces=yes

[Install]
WantedBy=multi-user.target
```

## Deploy scripts

Add these all to a `bin` dir in your project (create it if it doesn't exist). Don't forget to make
them executable.

`bin/post-receive`:
```
#!/bin/bash

cd ..

# WARNING: this will remove any local changes
env -i /usr/bin/git reset --hard

. ~/.bash_profile

unset GIT_DIR
mkdir -p log tmp

nice -19 bin/deploy
```

`bin/deploy-setup`:
```
#!/bin/bash

# Run one time to set up production deployment (git push production)

# Step 1: [server]: mkdir ~/[site]_git && cd ~/[site]_git && git init && git config receive.denyCurrentBranch ignore
# Step 2: [local]: git push production
# Step 3: [server]: git reset --hard
# Step 4: [server]: bin/deploy-setup && bin/deploy
#
# Don't forget to set SECRET_KEY_BASE, etc. in .bash_profile

cp bin/post-receive .git/hooks/post-receive

mix local.hex
mix local.rebar
```

`bin/deploy` (uncomment the compilation lines if you want to run webpack on the server... I usually don't):
```
#!/bin/bash

shopt -s expand_aliases
. ~/.bash_profile

RELNAME=`whoami`

mix deps.get && \
  # echo "Compiling assets..." && \
  # (cd assets && npm install && npm run deploy) && \
  echo "Digesting assets..." && \
  mix phx.digest && \
  echo "Building release..." && \
  mix release --overwrite &&
  rsync -acP _build/prod/rel/${RELNAME}/ ../sites/${RELNAME} && \
  echo "Running migrations..." && \
  env POOL_SIZE=10 mix ecto.migrate && \
  cd ../sites/`whoami` && \
  passenger-config restart-app . && \
  echo "Application restarted." && \
  echo "Deploy completed successfully."
```

If you want to precompile assets and commit them to your repo before each deploy (recommended!):
`bin/compile_assets`:
```
#!/bin/bash

echo "Compiling assets..." && \
  (cd assets && npm install && npm run deploy) &&
  git add priv/static
```

Then follow the steps in `bin/deploy_setup`.
