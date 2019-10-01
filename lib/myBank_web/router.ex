defmodule MyBankWeb.Router do
  use MyBankWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
  end

  scope "/api/v1", MyBankWeb do
    pipe_through :api

    post "/login", UserController, :login
  end

  scope "/api/v1", MyBankWeb do
    pipe_through [:api, :jwt_authenticated]

    scope "/account/:id" do
      get "/", AccountController, :index
      post "/transfer/:destination", AccountController, :transfer
    end
  end
end
