defmodule PhoenixFirstWeb.CounterLive.Counter do
  use PhoenixFirstWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>Counter</.header>
      <div class="flex space-x-4">
        <.button phx-click="down">Down</.button>
        <div class="w-16 font-bold font-mono font-2xl text-center">{@counter}</div>
        <.button phx-click="up">Up</.button>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Counter", counter: 0)}
  end

  @impl true
  def handle_event("up", _params, socket) do
    {:noreply, assign(socket, counter: socket.assigns.counter + 1)}
  end

  @impl true
  def handle_event("down", _params, socket) do
    {:noreply, assign(socket, counter: socket.assigns.counter - 1)}
  end
end
