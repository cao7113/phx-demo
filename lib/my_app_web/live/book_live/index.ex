defmodule MyAppWeb.BookLive.Index do
  use MyAppWeb, :live_view

  alias MyApp.Books

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Books
        <:actions>
          <.button variant="primary" navigate={~p"/books/new"}>
            <.icon name="hero-plus" /> New Book
          </.button>
        </:actions>
      </.header>

      <.table
        id="books"
        rows={@streams.books}
        row_click={fn {_id, book} -> JS.navigate(~p"/books/#{book}") end}
      >
        <:col :let={{_id, book}} label="Title">{book.title}</:col>
        <:col :let={{_id, book}} label="Note">{book.note}</:col>
        <:action :let={{_id, book}}>
          <div class="sr-only">
            <.link navigate={~p"/books/#{book}"}>Show</.link>
          </div>
          <.link navigate={~p"/books/#{book}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, book}}>
          <.link
            phx-click={JS.push("delete", value: %{id: book.id}) |> hide("##{id}")}
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
      Books.subscribe_books(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Books")
     |> stream(:books, list_books(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    book = Books.get_book!(socket.assigns.current_scope, id)
    {:ok, _} = Books.delete_book(socket.assigns.current_scope, book)

    {:noreply, stream_delete(socket, :books, book)}
  end

  @impl true
  def handle_info({type, %MyApp.Books.Book{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :books, list_books(socket.assigns.current_scope), reset: true)}
  end

  defp list_books(current_scope) do
    Books.list_books(current_scope)
  end
end
