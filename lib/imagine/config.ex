defmodule Imagine.Config do
  def version, do: Application.spec(:imagine_cms, :vsn)

  @build_number System.cmd("git", ["rev-list", "HEAD", "--count"]) |> elem(0) |> String.trim()
  def build_number, do: @build_number

  def release_built_at, do: DateTime.utc_now()
end
