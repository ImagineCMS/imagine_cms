defmodule Imagine.ReleaseTasks do
  @moduledoc """
  ReleaseTasks - allows us to run database migrations in production without Mix
  """

  def migrate do
    {:ok, _} = Application.ensure_all_started(:imagine_cms)
    path = Application.app_dir(:imagine_cms, "priv/repo/migrations")
    Ecto.Migrator.run(Imagine.Repo, path, :up, all: true)
  end
end
