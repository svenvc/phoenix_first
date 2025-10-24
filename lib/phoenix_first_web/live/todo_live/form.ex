defmodule PhoenixFirstWeb.TodoLive.Form do
  use PhoenixFirstWeb, :live_view

  alias PhoenixFirst.Todos
  alias PhoenixFirst.Todos.Todo

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage todo records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="todo-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:due]} type="date" label="Due" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Todo</.button>
          <.button navigate={return_path(@current_scope, @return_to, @todo)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    todo = Todos.get_todo!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Todo")
    |> assign(:todo, todo)
    |> assign(:form, to_form(Todos.change_todo(socket.assigns.current_scope, todo)))
  end

  defp apply_action(socket, :new, _params) do
    todo = %Todo{user_id: socket.assigns.current_scope.user.id, due: Date.utc_today()}

    socket
    |> assign(:page_title, "New Todo")
    |> assign(:todo, todo)
    |> assign(:form, to_form(Todos.change_todo(socket.assigns.current_scope, todo)))
  end

  @impl true
  def handle_event("validate", %{"todo" => todo_params}, socket) do
    changeset = Todos.change_todo(socket.assigns.current_scope, socket.assigns.todo, todo_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"todo" => todo_params}, socket) do
    save_todo(socket, socket.assigns.live_action, todo_params)
  end

  defp save_todo(socket, :edit, todo_params) do
    case Todos.update_todo(socket.assigns.current_scope, socket.assigns.todo, todo_params) do
      {:ok, todo} ->
        {:noreply,
         socket
         |> put_flash(:info, "Todo updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, todo)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_todo(socket, :new, todo_params) do
    case Todos.create_todo(socket.assigns.current_scope, todo_params) do
      {:ok, todo} ->
        {:noreply,
         socket
         |> put_flash(:info, "Todo created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, todo)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _todo), do: ~p"/todos"
  defp return_path(_scope, "show", todo), do: ~p"/todos/#{todo}"
end
