defmodule Imagine.Accounts.User do
  @moduledoc """
  User - for authentication, authorization, auditing
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :current_password, :string, virtual: true
    field :password, :string, virtual: true
    field :password_hash, :string
    field :password_hash_type, :string

    field :first_name, :string
    field :last_name, :string
    field :email, :string

    field :dynamic_fields, :string

    field :active, :boolean, default: false
    field :is_superuser, :boolean, default: false

    timestamps(inserted_at: :created_on, updated_at: :updated_on)
  end

  def name(user) do
    names = [to_string(user.first_name), to_string(user.last_name)]

    case names do
      ["", ""] -> user.email
      _ -> Enum.join(names, " ")
    end
  end

  @doc false
  def changeset(user, attrs) do
    case to_string(attrs["password"] || attrs[:password]) do
      "" ->
        user
        |> cast(attrs, [:username, :first_name, :last_name, :email, :active])
        |> validate_required([:username, :email, :active])

      _ ->
        changeset_with_password(user, attrs)
    end
  end

  def changeset_with_password(user, attrs) do
    user
    |> cast(attrs, [:username, :password, :first_name, :last_name, :email, :active])
    |> validate_required([:username, :password, :email, :active])
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> put_pass_hash()
  end

  def change_password_changeset(user, attrs) do
    user
    |> cast(attrs, [:current_password, :password])
    |> validate_required([:current_password, :password])
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> validate_current_password(user)
    |> put_pass_hash()
  end

  # def registration_changeset(user, attrs) do
  #   user
  #   |> cast(attrs, [:username, :password, :first_name, :last_name, :email])
  #   |> put_change(:active, true)
  #   |> validate_length(:password, min: 8)
  #   |> validate_confirmation(:password)
  #   |> put_pass_hash()
  # end

  @doc false
  def is_superuser_changeset(user, attrs) do
    user
    |> cast(attrs, [:is_superuser])
    |> validate_required([:is_superuser])
  end

  defp validate_current_password(
         %Ecto.Changeset{valid?: true, changes: %{current_password: password}} = changeset,
         user
       ) do
    case check_password(user, password) do
      true -> changeset
      false -> add_error(changeset, :current_password, "is not correct")
    end
  end

  defp validate_current_password(changeset, _user), do: changeset

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    %{password_hash: hash} = Argon2.add_hash(password)

    changeset
    |> put_change(:password_hash, hash)
    |> put_change(:password_hash_type, "argon2")
  end

  defp put_pass_hash(changeset), do: changeset

  # works with new argon2 hashes and legacy sha1 hashes (and others can be added)
  # every legacy installation should have used the default 16-char salt
  # ... but if not, we'll find out pretty quick
  def check_password(%__MODULE__{} = user, password, saltlen \\ 16) do
    case user.password_hash_type do
      "argon2" ->
        Argon2.verify_pass(password, user.password_hash)

      _ ->
        # legacy hash
        salt = String.slice(user.password_hash, 0..(saltlen - 1))
        legacy_sha1_hash(password, salt) == user.password_hash
    end
  end

  def legacy_sha1_hash(password, salt) do
    hash = :crypto.hash(:sha, salt <> password) |> Base.encode16() |> String.downcase()
    salt <> hash
  end
end
