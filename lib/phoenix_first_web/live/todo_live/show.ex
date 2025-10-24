defmodule PhoenixFirstWeb.TodoLive.Show do
  use PhoenixFirstWeb, :live_view

  alias PhoenixFirst.Todos

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Todo {@todo.id}
        <:subtitle>This is a todo record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/todos"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/todos/#{@todo}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit todo
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Description">{@todo.description}</:item>
        <:item title="Due">{@todo.due}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Todos.subscribe_todos(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Todo")
     |> assign(:todo, Todos.get_todo!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %PhoenixFirst.Todos.Todo{id: id} = todo},
        %{assigns: %{todo: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :todo, todo)}
  end

  def handle_info(
        {:deleted, %PhoenixFirst.Todos.Todo{id: id}},
        %{assigns: %{todo: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current todo was deleted.")
     |> push_navigate(to: ~p"/todos")}
  end

  def handle_info({type, %PhoenixFirst.Todos.Todo{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
