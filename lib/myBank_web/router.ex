defmodule MyBankWeb.Router do
  use MyBankWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :authenticated do
    plug :authenticated_user
  end

  scope "/api/v1", MyBankWeb do
    pipe_through :api

    post "/login", UserController, :login
  end

  scope "/api/v1", MyBankWeb do
    pipe_through [:api, :authenticated]

    scope "/account/:id" do
      get "/", AccountController, :index
      post "/transfer/:destination", AccountController, :transfer
    end
  end

  defp authenticated_user(conn, _) do
    if get_session(conn, :user) == nil do
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "User not authenticated"})
      |> halt()
    else
      conn
    end
  end
end
