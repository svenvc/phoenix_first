defmodule PhoenixFirst.Todos do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias PhoenixFirst.Repo

  alias PhoenixFirst.Todos.Todo
  alias PhoenixFirst.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any todo changes.

  The broadcasted messages match the pattern:

    * {:created, %Todo{}}
    * {:updated, %Todo{}}
    * {:deleted, %Todo{}}

  """
  def subscribe_todos(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(PhoenixFirst.PubSub, "user:#{key}:todos")
  end

  defp broadcast_todo(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(PhoenixFirst.PubSub, "user:#{key}:todos", message)
  end

  @doc """
  Returns the list of todos.

  ## Examples

      iex> list_todos(scope)
      [%Todo{}, ...]

  """
  def list_todos(%Scope{} = scope) do
    Repo.all_by(Todo, user_id: scope.user.id)
  end

  @doc """
  Gets a single todo.

  Raises `Ecto.NoResultsError` if the Todo does not exist.

  ## Examples

      iex> get_todo!(scope, 123)
      %Todo{}

      iex> get_todo!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_todo!(%Scope{} = scope, id) do
    Repo.get_by!(Todo, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a todo.

  ## Examples

      iex> create_todo(scope, %{field: value})
      {:ok, %Todo{}}

      iex> create_todo(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_todo(%Scope{} = scope, attrs) do
    with {:ok, todo = %Todo{}} <-
           %Todo{}
           |> Todo.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_todo(scope, {:created, todo})
      {:ok, todo}
    end
  end

  @doc """
  Updates a todo.

  ## Examples

      iex> update_todo(scope, todo, %{field: new_value})
      {:ok, %Todo{}}

      iex> update_todo(scope, todo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_todo(%Scope{} = scope, %Todo{} = todo, attrs) do
    true = todo.user_id == scope.user.id

    with {:ok, todo = %Todo{}} <-
           todo
           |> Todo.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_todo(scope, {:updated, todo})
      {:ok, todo}
    end
  end

  @doc """
  Deletes a todo.

  ## Examples

      iex> delete_todo(scope, todo)
      {:ok, %Todo{}}

      iex> delete_todo(scope, todo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_todo(%Scope{} = scope, %Todo{} = todo) do
    true = todo.user_id == scope.user.id

    with {:ok, todo = %Todo{}} <-
           Repo.delete(todo) do
      broadcast_todo(scope, {:deleted, todo})
      {:ok, todo}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking todo changes.

  ## Examples

      iex> change_todo(scope, todo)
      %Ecto.Changeset{data: %Todo{}}

  """
  def change_todo(%Scope{} = scope, %Todo{} = todo, attrs \\ %{}) do
    true = todo.user_id == scope.user.id

    Todo.changeset(todo, attrs, scope)
  end
end
