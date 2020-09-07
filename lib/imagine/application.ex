defmodule Imagine.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      Imagine.Repo,
      Imagine.Cache,
      %{
        id: NodeJS,
        start:
          {NodeJS, :start_link,
           [[path: Application.app_dir(:imagine_cms, "priv/js"), pool_size: 2]]}
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Imagine.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(_changed, _new, _removed) do
    # ImagineWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
