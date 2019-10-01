defmodule MyBankWeb.AccountControllerTest do
  use MyBankWeb.ConnCase

  alias MyBank.Accounts

  # @create_attrs [%{account_id: 1515, balance: 51.25, value: 0, description: "initial value"},
  #                 %{account_id: 2020, balance: 68.12, value: 0, description: "initial value"}]

  @create_user_attrs %{name: "Fabrício", email: "bill@aoc.com", password_hash: "200820e3227815ed1756a6b531e7e0d2"}

  describe "index/2" do
    setup [:create_user]

    test "Responds with account info if the account is found", %{conn: conn, user: user} do
      {:ok, account} = Accounts.create_account(%{balance: 51.25, value: 51.25, description: "initial value"}, user)

      response =
        conn
        |> get(Routes.account_path(conn, :index, account.user_id))
        |> json_response(200)

      expected = %{"data" => %{"account_id" => account.user_id, "balance" => account.balance}}

      assert response == expected
    end

    test "Responds with a message indicating account not found", %{conn:  conn} do
      conn = get(conn, Routes.account_path(conn, :index, -1))

      assert text_response(conn, 404) == "Account not found"
    end
  end

  # describe "transfer/2" do
  #     setup [:create_transfer_account]

  #     test "Transfer value and responds the new balance of the account", %{conn: conn, account1: account1} do

  #         response =
  #             conn
  #             |> post(Routes.account_path(conn, :transfer, account1.account_id, 2020, %{value: 30}))
  #             |> json_response(200)

  #         expected = %{"data" => %{"account_id" => account1.account_id, "balance" => 21.25}}

  #         assert response == expected
  #     end
  # end

  # defp create_transfer_account(_) do
  #     [{:ok, account1}, {:ok, account2}] = Enum.map(@create_attrs, &Accounting.create_account(&1))
  #     {:ok, account1: account1, account2: account2}
  # end

  defp create_user(_) do
      {:ok, user} = Accounts.create_user(@create_user_attrs)
      {:ok, user: user}
  end
end
