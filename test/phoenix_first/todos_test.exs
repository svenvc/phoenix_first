defmodule PhoenixFirst.TodosTest do
  use PhoenixFirst.DataCase

  alias PhoenixFirst.Todos

  describe "todos" do
    alias PhoenixFirst.Todos.Todo

    import PhoenixFirst.AccountsFixtures, only: [user_scope_fixture: 0]
    import PhoenixFirst.TodosFixtures

    @invalid_attrs %{description: nil, due: nil}

    test "list_todos/1 returns all scoped todos" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      todo = todo_fixture(scope)
      other_todo = todo_fixture(other_scope)
      assert Todos.list_todos(scope) == [todo]
      assert Todos.list_todos(other_scope) == [other_todo]
    end

    test "get_todo!/2 returns the todo with given id" do
      scope = user_scope_fixture()
      todo = todo_fixture(scope)
      other_scope = user_scope_fixture()
      assert Todos.get_todo!(scope, todo.id) == todo
      assert_raise Ecto.NoResultsError, fn -> Todos.get_todo!(other_scope, todo.id) end
    end

    test "create_todo/2 with valid data creates a todo" do
      valid_attrs = %{description: "some description", due: ~D[2025-10-23]}
      scope = user_scope_fixture()

      assert {:ok, %Todo{} = todo} = Todos.create_todo(scope, valid_attrs)
      assert todo.description == "some description"
      assert todo.due == ~D[2025-10-23]
      assert todo.user_id == scope.user.id
    end

    test "create_todo/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Todos.create_todo(scope, @invalid_attrs)
    end

    test "update_todo/3 with valid data updates the todo" do
      scope = user_scope_fixture()
      todo = todo_fixture(scope)
      update_attrs = %{description: "some updated description", due: ~D[2025-10-24]}

      assert {:ok, %Todo{} = todo} = Todos.update_todo(scope, todo, update_attrs)
      assert todo.description == "some updated description"
      assert todo.due == ~D[2025-10-24]
    end

    test "update_todo/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      todo = todo_fixture(scope)

      assert_raise MatchError, fn ->
        Todos.update_todo(other_scope, todo, %{})
      end
    end

    test "update_todo/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      todo = todo_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Todos.update_todo(scope, todo, @invalid_attrs)
      assert todo == Todos.get_todo!(scope, todo.id)
    end

    test "delete_todo/2 deletes the todo" do
      scope = user_scope_fixture()
      todo = todo_fixture(scope)
      assert {:ok, %Todo{}} = Todos.delete_todo(scope, todo)
      assert_raise Ecto.NoResultsError, fn -> Todos.get_todo!(scope, todo.id) end
    end

    test "delete_todo/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      todo = todo_fixture(scope)
      assert_raise MatchError, fn -> Todos.delete_todo(other_scope, todo) end
    end

    test "change_todo/2 returns a todo changeset" do
      scope = user_scope_fixture()
      todo = todo_fixture(scope)
      assert %Ecto.Changeset{} = Todos.change_todo(scope, todo)
    end
  end
end
