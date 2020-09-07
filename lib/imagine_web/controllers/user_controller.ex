defmodule ImagineWeb.UserController do
  use ImagineWeb, :controller

  alias Imagine.Accounts
  alias Imagine.Accounts.User

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", page_title: "New User < Users", users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{active: true})
    render(conn, "new.html", page_title: "New User < Users", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", page_title: "New User < Users", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.html", page_title: "#{user.username} < Users", user: user)
  end

  def disable(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, %{active: false}) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User disabled.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn,
          page_title: "Edit #{user.username} < Users",
          user: user,
          changeset: changeset
        )
    end
  end

  def enable(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, %{active: true}) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User enabled.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn,
          page_title: "Edit #{user.username} < Users",
          user: user,
          changeset: changeset
        )
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)

    render(conn, "edit.html",
      page_title: "Edit #{user.username} < Users",
      user: user,
      changeset: changeset
    )
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          page_title: "Edit #{user.username} < Users",
          user: user,
          changeset: changeset
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    {:ok, _user} = id |> Accounts.get_user!() |> Accounts.delete_user()

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end
end
