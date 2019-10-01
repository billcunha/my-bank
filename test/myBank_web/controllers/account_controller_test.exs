defmodule MyBankWeb.AccountControllerTest do
  use MyBankWeb.ConnCase

  alias MyBank.Accounts

  @create_transfer_users_attrs [%{name: "Fabrício", email: "bill@aoc.com", password_hash: "200820e3227815ed1756a6b531e7e0d2"},
                                %{name: "Jessica", email: "jessica@aoc.com", password_hash: "200820e3227815ed1756a6b531e7e0d2"}]

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

  describe "transfer/2" do
    setup [:create_transfer_account]

    test "Transfer value and responds the new balance of the account", %{conn: conn, account1: account1, account2: account2} do

      response =
        conn
        |> post(Routes.account_path(conn, :transfer, account1.user_id, account2.user_id, %{value: 30}))
        |> json_response(200)

      expected = %{"data" => %{"account_id" => account1.user_id, "balance" => 21.25}}

      assert response == expected
    end

    test "Try transfer value bigger then balance of the account", %{conn: conn, account1: account1, account2: account2} do

      response =
        conn
        |> post(Routes.account_path(conn, :transfer, account1.user_id, account2.user_id, %{value: 680}))
        |> json_response(404)

      expected = %{"message" => "Balance not sufficient"}

      assert response == expected
    end

    test "Try transfer to a inexistent account", %{conn: conn, account1: account1} do

      response =
        conn
        |> post(Routes.account_path(conn, :transfer, account1.user_id, -1, %{value: 30}))
        |> json_response(404)

      expected = %{"message" => "Destination account not found"}

      assert response == expected
    end

    test "Try transfer from a inexistent account", %{conn: conn, account2: account2} do

      response =
        conn
        |> post(Routes.account_path(conn, :transfer, -1, account2.user_id, %{value: 30}))
        |> json_response(404)

      expected = %{"message" => "Source account not found"}

      assert response == expected
    end
  end

  defp create_transfer_account(_) do
    [{:ok, user1}, {:ok, user2}] = Enum.map(@create_transfer_users_attrs, &Accounts.create_user(&1))

    {:ok, account1} = Accounts.create_account(%{balance: 51.25, value: 51.25, description: "initial value"}, user1)
    {:ok, account2} = Accounts.create_account(%{balance: 18.34, value: 18.34, description: "initial value"}, user2)

    {:ok, account1: account1, account2: account2}
  end

  defp create_user(_) do
      {:ok, user} = Accounts.create_user(@create_user_attrs)
      {:ok, user: user}
  end
end
