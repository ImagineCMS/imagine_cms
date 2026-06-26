# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :esbuild,
  version: "0.25.5",
  frontend: [
    args:
      ~w(frontend.js --bundle --target=es2017 --outfile=../priv/static/js/imagine_cms.js --external:/assets/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ],
  manage: [
    args:
      ~w(manage.js --bundle --target=es2017 --outfile=../priv/static/js/manage.js --external:/assets/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :dart_sass,
  version: "1.77.8",
  frontend: [
    args: ~w(frontend.scss ../priv/static/css/imagine_cms.css),
    cd: Path.expand("../assets", __DIR__)
  ],
  manage: [
    args: ~w(manage.scss ../priv/static/css/manage.css),
    cd: Path.expand("../assets", __DIR__)
  ]
