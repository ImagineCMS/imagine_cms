defmodule ImagineWeb.CmsController do
  use ImagineWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
