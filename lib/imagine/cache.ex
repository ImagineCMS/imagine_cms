defmodule Imagine.Cache do
  use Nebulex.Cache,
    otp_app: :imagine_cms,
    adapter: Nebulex.Adapters.Local
end
