defmodule MyAppWeb.Admin.DemoLive do
  use MyAppWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Demo")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      Demo blank page
    </div>
    """
  end
end
