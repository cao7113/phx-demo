defmodule MyAppWeb.Admin.BookLive.Index do
  use MyAppWeb, :live_view
  import MyAppWeb.AdminComponents, only: [pagination: 1]

  alias MyApp.Books.Admin

  @per_page 20

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Books")
     |> assign(:search, "")
     |> assign(:sort, "inserted_at:desc")
     |> assign(:page, 1)
     |> reload_books()}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    {:noreply, socket |> assign(search: query, page: 1) |> reload_books()}
  end

  def handle_event("sort", %{"sort" => sort}, socket) do
    {:noreply, socket |> assign(sort: sort, page: 1) |> reload_books()}
  end

  def handle_event("paginate", %{"page" => page}, socket) do
    {:noreply, socket |> assign(:page, String.to_integer(page)) |> reload_books()}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    book = Admin.get_book!(id)
    {:ok, _} = Admin.delete_book(socket.assigns.current_scope, book)

    {:noreply,
     socket
     |> put_flash(:info, "Book deleted.")
     |> stream_delete(:books, book)}
  end

  defp reload_books(socket) do
    %{search: search, sort: sort, page: page} = socket.assigns
    [field, dir] = String.split(sort, ":")

    %{entries: books, total_pages: total_pages} =
      Admin.paginate_books(
        search: search,
        sort_by: String.to_existing_atom(field),
        sort_dir: String.to_existing_atom(dir),
        page: page,
        per_page: @per_page
      )

    socket
    |> assign(:total_pages, total_pages)
    |> stream(:books, books, reset: true)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <.header>
        Books
        <:actions>
          <.link navigate={~p"/admin/books/new"} class="btn btn-primary">
            <.icon name="hero-plus" class="w-4 h-4" /> New Book
          </.link>
        </:actions>
      </.header>

      <div class="flex items-center gap-3">
        <form phx-change="search" class="w-72">
          <input
            type="text"
            name="q"
            value={@search}
            placeholder="Search by title or note…"
            class="input input-bordered w-full"
          />
        </form>

        <form phx-change="sort">
          <select name="sort" class="select select-bordered">
            <option value="inserted_at:desc" selected={@sort == "inserted_at:desc"}>
              Newest first
            </option>
            <option value="inserted_at:asc" selected={@sort == "inserted_at:asc"}>
              Oldest first
            </option>
            <option value="title:asc" selected={@sort == "title:asc"}>Title A–Z</option>
            <option value="title:desc" selected={@sort == "title:desc"}>Title Z–A</option>
          </select>
        </form>
      </div>

      <div class="bg-base-100 rounded-xl border border-base-300 overflow-hidden">
        <.table id="books" rows={@streams.books}>
          <:col :let={{_id, book}} label="Title">{book.title}</:col>
          <:col :let={{_id, book}} label="Note">{book.note}</:col>
          <:col :let={{_id, book}} label="Owner">
            {book.user && book.user.email}
          </:col>
          <:col :let={{_id, book}} label="Added">
            {Calendar.strftime(book.inserted_at, "%b %d, %Y")}
          </:col>
          <:action :let={{_id, book}}>
            <.link navigate={~p"/admin/books/#{book.id}/edit"} class="btn btn-xs btn-ghost">
              Edit
            </.link>
          </:action>
          <:action :let={{id, book}}>
            <button
              phx-click={JS.push("delete", value: %{id: book.id}) |> hide("##{id}")}
              data-confirm="Are you sure?"
              class="btn btn-xs btn-ghost text-error"
            >
              Delete
            </button>
          </:action>
        </.table>
        <.pagination page={@page} total_pages={@total_pages} />
      </div>
    </div>
    """
  end
end
