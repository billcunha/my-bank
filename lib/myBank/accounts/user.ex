defmodule MyBank.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias MyBank.Accounts.Account

  schema "users" do
    field :email, :string
    field :name, :string
    field :password_hash, :string
    has_one :account, Account

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :password_hash])
    |> validate_required([:email, :name, :password_hash])
    |> unique_constraint(:email)
  end
end
