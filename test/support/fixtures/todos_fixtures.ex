defmodule PhoenixFirst.TodosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PhoenixFirst.Todos` context.
  """

  @doc """
  Generate a todo.
  """
  def todo_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        due: ~D[2025-10-23]
      })

    {:ok, todo} = PhoenixFirst.Todos.create_todo(scope, attrs)
    todo
  end
end
