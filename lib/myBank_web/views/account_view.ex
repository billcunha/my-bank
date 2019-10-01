defmodule MyBankWeb.AccountView do
  use MyBankWeb, :view
  alias MyBankWeb.AccountView

  def render("index.json", %{accounts: accounts}) do
    %{data: render_many(accounts, AccountView, "account.json")}
  end

  def render("show.json", %{account: account}) do
    %{data: render_one(account, AccountView, "account.json")}
  end

  def render("account.json", %{account: account}) do
    %{account_id: account.user_id,
      balance: account.balance}
  end
end
