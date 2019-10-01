defmodule MyBank.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  alias MyBank.Accounts.User

  schema "accounts" do
    field :balance, :float
    field :description, :string
    field :value, :float
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:balance, :value, :description])
    |> validate_required([:balance, :value, :description])
  end
end
