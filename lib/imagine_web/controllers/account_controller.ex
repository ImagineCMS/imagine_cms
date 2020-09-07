defmodule ImagineWeb.AccountController do
  use ImagineWeb, :controller

  alias Imagine.Accounts
  require Logger

  def edit(conn, _params) do
    user = conn.assigns[:current_user]
    changeset = Accounts.change_user(user)

    render(conn, "edit.html", page_title: "Account", changeset: changeset)
  end

  def update(conn, %{"user" => attrs}) do
    user = conn.assigns[:current_user]

    case Accounts.update_user_change_password(user, attrs) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Account updated successfully.")
        |> redirect(to: Routes.account_path(conn, :edit))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", page_title: "Account", changeset: changeset)
    end
  end
end
