defmodule Imagine.Config do
  def version, do: Imagine.MixProject.project()[:version]

  def build_number,
    do: System.cmd("git", ["rev-list", "HEAD", "--count"]) |> elem(0) |> String.trim()

  def release_built_at, do: DateTime.utc_now()
end
