defmodule MyBankWeb.UserControllerTest do
    use MyBankWeb.ConnCase
  
    alias MyBank.Accounts
  
    @create_user_attrs %{name: "Fabrício", email: "fabricio@aoc.com", password_hash: "f800e56c0846b22e3a76eb04c3d31ba8746527fa"}
  
    describe "login/2" do
  
      test "Success login", %{conn: conn} do
        {:ok, user} = Accounts.create_user(@create_user_attrs)
  
        response =
          conn
          |> post(Routes.user_path(conn, :login, %{email: user.email, password: "fabricio"}))
          |> json_response(200)
  
        expected = %{"ok" => "done"}
  
        assert response == expected
      end

      test "Fail login", %{conn: conn} do
        response =
          conn
          |> post(Routes.user_path(conn, :login, %{email: "Fail", password: "fail"}))
          |> json_response(401)
  
        expected = %{"error" => "Login error"}
  
        assert response == expected
      end
    end
  end
  