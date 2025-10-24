defmodule PhoenixFirstWeb.PageController do
  use PhoenixFirstWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
