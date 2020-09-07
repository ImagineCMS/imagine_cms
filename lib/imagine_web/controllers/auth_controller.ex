defmodule ImagineWeb.AuthController do
  use ImagineWeb, :controller

  alias Imagine.Accounts
  alias Imagine.Accounts.User

  def login(conn, params) do
    conn
    |> assign(:csrf_token, get_csrf_token())
    |> assign(:return_to, params["return_to"])
    |> render("login.html")
  end

  def handle_login(conn, %{"user" => %{"username" => username}} = params) do
    user = Accounts.get_user_by_username_or_email(username)
    password = params["user"]["password"]

    return_to =
      if params["system"]["return_to"] == "",
        do: Routes.cms_path(conn, :index),
        else: params["system"]["return_to"]

    case user && User.check_password(user, password) do
      true ->
        conn
        |> Plug.Conn.put_session(:user_id, user.id)
        |> put_flash(:notice, "Logged in successfully.")
        |> redirect(to: return_to)

      _ ->
        conn
        |> put_flash(:error, "Invalid username or password, please try again.")
        |> assign(:csrf_token, get_csrf_token())
        |> assign(:return_to, return_to)
        |> render("login.html")
    end
  end

  def handle_logout(conn, _params) do
    conn
    |> Plug.Conn.delete_session(:user_id)
    |> put_flash(:notice, "You have been logged out of the system.")
    |> redirect(to: Routes.auth_path(conn, :login))
  end
end
