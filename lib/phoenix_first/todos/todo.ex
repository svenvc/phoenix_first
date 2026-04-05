defmodule PhoenixFirst.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :description, :string
    field :due, :date
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(todo, attrs, user_scope) do
    todo
    |> cast(attrs, [:description, :due])
    |> validate_required([:description, :due])
    |> validate_change(:due, fn :due, due ->
      if Date.before?(due, Date.utc_today()) do
        [due: "cannot be before today"]
      else
        []
      end
    end)
    |> put_change(:user_id, user_scope.user.id)
  end
end
