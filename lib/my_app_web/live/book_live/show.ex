defmodule MyAppWeb.BookLive.Show do
  use MyAppWeb, :live_view

  alias MyApp.Books

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Book {@book.id}
        <:subtitle>This is a book record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/books"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/books/#{@book}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit book
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@book.title}</:item>
        <:item title="Note">{@book.note}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Books.subscribe_books(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Book")
     |> assign(:book, Books.get_book!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %MyApp.Books.Book{id: id} = book},
        %{assigns: %{book: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :book, book)}
  end

  def handle_info(
        {:deleted, %MyApp.Books.Book{id: id}},
        %{assigns: %{book: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current book was deleted.")
     |> push_navigate(to: ~p"/books")}
  end

  def handle_info({type, %MyApp.Books.Book{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
