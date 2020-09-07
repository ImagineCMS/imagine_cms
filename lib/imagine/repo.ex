defmodule Imagine.Repo do
  use Ecto.Repo,
    otp_app: :imagine_cms,
    adapter: Ecto.Adapters.MyXQL
end
