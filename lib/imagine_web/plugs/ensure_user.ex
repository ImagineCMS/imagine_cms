defmodule ImagineWeb.Plugs.EnsureUser do
  @moduledoc """
  EnsureUser plug - redirects to login if conn.assigns[:current_user] is not present
  """

  import Plug.Conn
  import Phoenix.Controller
  alias ImagineWeb.Router.Helpers, as: Routes

  @spec init(any) :: any
  def init(opts), do: opts

  def call(%{assigns: %{current_user: _user}} = conn, _opts) do
    conn
  end

  def call(conn, _opts) do
    conn
    |> put_flash(:notice, "This is an admin-only function. To continue, please log in.")
    |> redirect(to: Routes.auth_path(conn, :login))
    |> halt()
  end
end
