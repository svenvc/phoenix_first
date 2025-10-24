defmodule PhoenixFirstWeb.TodoLive.Index do
  use PhoenixFirstWeb, :live_view

  alias PhoenixFirst.Todos

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Todos
        <:actions>
          <.button variant="primary" navigate={~p"/todos/new"}>
            <.icon name="hero-plus" /> New Todo
          </.button>
        </:actions>
      </.header>

      <.table
        id="todos"
        rows={@streams.todos}
        row_click={fn {_id, todo} -> JS.navigate(~p"/todos/#{todo}") end}
      >
        <:col :let={{_id, todo}} label="Description">{todo.description}</:col>
        <:col :let={{_id, todo}} label="Due">{todo.due}</:col>
        <:action :let={{_id, todo}}>
          <div class="sr-only">
            <.link navigate={~p"/todos/#{todo}"}>Show</.link>
          </div>
          <.link navigate={~p"/todos/#{todo}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, todo}}>
          <.link
            phx-click={JS.push("delete", value: %{id: todo.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Todos.subscribe_todos(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Todos")
     |> stream(:todos, list_todos(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    todo = Todos.get_todo!(socket.assigns.current_scope, id)
    {:ok, _} = Todos.delete_todo(socket.assigns.current_scope, todo)

    {:noreply, stream_delete(socket, :todos, todo)}
  end

  @impl true
  def handle_info({type, %PhoenixFirst.Todos.Todo{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :todos, list_todos(socket.assigns.current_scope), reset: true)}
  end

  defp list_todos(current_scope) do
    Todos.list_todos(current_scope)
  end
end
