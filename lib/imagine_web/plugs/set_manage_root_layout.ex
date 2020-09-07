defmodule ImagineWeb.Plugs.SetManageRootLayout do
  @moduledoc """
  SetManageLayout plug - sets root layout to manage.html
  """

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    Phoenix.Controller.put_root_layout(conn, {ImagineWeb.LayoutView, :manage})
  end
end
