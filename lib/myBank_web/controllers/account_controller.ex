defmodule MyBankWeb.AccountController do
  use MyBankWeb, :controller

  alias MyBank.Accounts
  alias MyBank.Accounts.Account

  action_fallback MyBankWeb.FallbackController

  def index(conn, %{"id" => account_id}) do
    case Accounts.get_balance(account_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> text("Account not found")

      account -> 
        render(conn, "show.json", account: account)
    end
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.create_account(account_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.account_path(conn, :show, account))
      |> render("show.json", account: account)
    end
  end

  def show(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    render(conn, "show.json", account: account)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{} = account} <- Accounts.update_account(account, account_params) do
      render(conn, "show.json", account: account)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{}} <- Accounts.delete_account(account) do
      send_resp(conn, :no_content, "")
    end
  end

  def transfer(conn, %{"id" => id, "destination" => destination_account_id, "value" => value}) do
    {ammount, _} = if is_integer(value) == true, do: value, else: Integer.parse(value)
    {source_account_id, _} = if is_integer(id) == true, do: value, else: Integer.parse(id)

    case Accounts.transfer(source_account_id, destination_account_id, ammount) do
      {:error, message: message} ->
        conn
        |> put_status(:forbidden)
        |> json(%{message: message})

      {:ok, account: account} ->
        render(conn, "show.json", account: account)
    end
  end
end
