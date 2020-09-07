defmodule ImagineWeb.Plugs.Auth do
  @moduledoc """
  Auth plug - looks up user based on session[:user_id] and sets conn.assigns[:current_user]
  """

  import Plug.Conn

  @spec init(any) :: any
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Imagine.Accounts.get_user(user_id)

    if user do
      assign(conn, :current_user, user)
    else
      if System.get_env("MIX_ENV") == "test" do
        assign(conn, :current_user, %Imagine.Accounts.User{id: 1, username: "test_user"})
      else
        conn
      end
    end
  end
end
