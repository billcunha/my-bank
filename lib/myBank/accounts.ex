defmodule MyBank.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias MyBank.Repo

  alias MyBank.Accounts.User

  alias MyBank.Guardian
  import Comeonin.Bcrypt, only: [dummy_checkpw: 0]
  import Bcrypt, only: [verify_pass: 2]

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  alias MyBank.Accounts.Account

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
    Repo.all(Account)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id)

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}, %User{} = user) do
    %Account{}
    |> Account.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{source: %Account{}}

  """
  def change_account(%Account{} = account) do
    Account.changeset(account, %{})
  end

  def get_balance(account_id) do
    Account |> where(user_id: ^account_id) |> last(:inserted_at) |> Repo.one
  end

  def transfer(source_account_id, destination_account_id, value) do
    case get_balance(source_account_id) do
      nil ->
        {:error, message: "Source account not found"}

      source_account ->
        cond do
          source_account.balance < value ->
            {:error, message: "Balance not sufficient"}

          source_account.balance >= value ->
            case get_balance(destination_account_id) do
              nil ->
                {:error, message: "Destination account not found"}

              destination_account ->
                source_user = get_user!(source_account_id)
                case create_account(%{account_id: source_account_id, description: "transfer", balance: source_account.balance - value, value: value}, source_user) do
                  {:ok, new_account} ->
                    destination_user = get_user!(destination_account_id)
                    case create_account(%{account_id: destination_account_id, description: "transfer", balance: destination_account.balance + value, value: value}, destination_user) do
                      {:ok, _} ->
                        {:ok, account: new_account}

                      :error ->
                        {:error, message: "Internal error"}
                    end
                  
                  :error ->
                    {:error, message: "Internal error"}
                end
            end
        end
    end
  end

  def authenticate(email, password) do
    case email_password_auth(email, password) do
      {:ok, user} ->
        {:ok, user: user}
      _ ->
        {:error, :unauthorized}
    end
  end

  defp email_password_auth(email, password) do
    with {:ok, user} <- get_by_email(email),
    do: verify_password(password, user)
  end

  defp get_by_email(email) do
    case Repo.get_by(User, email: email) do
      nil ->
        {:error, "Login error."}
      user ->
        {:ok, user}
    end
  end

  defp verify_password(password, %User{} = user) do
    hash = :crypto.hash(:sha, password) |> Base.encode16 |> String.downcase
    if (hash == user.password_hash) do
      {:ok, user}
    else
      {:error, :invalid_password}
    end
  end

  def token_sign_in(email, password) do
    case email_password_auth1(email, password) do
      {:ok, user} ->
        Guardian.encode_and_sign(user)
      _ ->
        {:error, :unauthorized}
    end
  end

  defp email_password_auth1(email, password) when is_binary(email) and is_binary(password) do
    with {:ok, user} <- get_by_email1(email),
    do: verify_password1(password, user)
  end

  defp get_by_email1(email) when is_binary(email) do
    case Repo.get_by(User, email: email) do
      nil ->
        dummy_checkpw()
        {:error, "Login error."}
      user ->
        {:ok, user}
    end
  end

  defp verify_password1(password, %User{} = user) when is_binary(password) do
    if verify_pass(password, Bcrypt.hash_pwd_salt("fabricio")) do
      {:ok, user}
    else
      {:error, :invalid_password}
    end
  end
end
