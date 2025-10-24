defmodule PhoenixFirst.Repo do
  use Ecto.Repo,
    otp_app: :phoenix_first,
    adapter: Ecto.Adapters.Postgres
end
