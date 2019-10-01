defmodule MyBank.Repo do
  use Ecto.Repo,
    otp_app: :myBank,
    adapter: Ecto.Adapters.Postgres
end
