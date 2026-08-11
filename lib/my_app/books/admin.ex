defmodule MyApp.Books.Admin do
  @moduledoc """
  Privileged operations on books for the admin area.

  These functions bypass the per-user scoping enforced by `MyApp.Books`:
  they operate on any book and let the caller choose the owner. The
  `%Scope{}` argument of the mutating functions is the *acting* admin —
  carried for logging and audit only, never used for authorization.

  Keep this module out of public-facing code paths — only the admin live
  views should call into it.
  """

  require Logger

  import Ecto.Query, warn: false

  alias MyApp.Accounts.Scope
  alias MyApp.Books
  alias MyApp.Books.Book
  alias MyApp.Repo

  @doc """
  Paginated, searchable list of all books, owner preloaded.

  ## Examples

      iex> paginate_books(search: "elixir", sort_by: :title, page: 1, per_page: 20)
      %{entries: [%Book{}], total_pages: 1, total_count: 1}

  """
  def paginate_books(opts \\ []) do
    search = Keyword.get(opts, :search, "")
    sort_by = Keyword.get(opts, :sort_by, :inserted_at)
    sort_dir = Keyword.get(opts, :sort_dir, :desc)
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)

    base_query =
      from b in Book,
        where: ilike(b.title, ^"%#{search}%") or ilike(b.note, ^"%#{search}%")

    total_count = Repo.aggregate(base_query, :count, :id)
    total_pages = max(ceil(total_count / per_page), 1)

    entries =
      base_query
      |> preload([:user])
      |> order_by([b], [{^sort_dir, field(b, ^sort_by)}])
      |> limit(^per_page)
      |> offset(^((page - 1) * per_page))
      |> Repo.all()

    %{entries: entries, total_pages: total_pages, total_count: total_count}
  end

  @doc "Gets a single book, raising if it does not exist."
  def get_book!(id), do: Repo.get!(Book, id)

  @doc """
  Creates a book for an arbitrary owner as the given admin, broadcasting
  the change to the owner's channel so their public book list live-updates.
  """
  def create_book(%Scope{} = scope, attrs) do
    with {:ok, book = %Book{}} <-
           %Book{}
           |> Book.changeset(attrs)
           |> Repo.insert() do
      log_action(scope, :created, book)
      Books.broadcast_book(book.user_id, {:created, book})
      {:ok, book}
    end
  end

  @doc "Updates any book as the given admin, broadcasting to its owner."
  def update_book(%Scope{} = scope, %Book{} = book, attrs) do
    with {:ok, book = %Book{}} <-
           book
           |> Book.changeset(attrs)
           |> Repo.update() do
      log_action(scope, :updated, book)
      Books.broadcast_book(book.user_id, {:updated, book})
      {:ok, book}
    end
  end

  @doc "Deletes any book as the given admin, broadcasting to its owner."
  def delete_book(%Scope{} = scope, %Book{} = book) do
    with {:ok, book = %Book{}} <-
           Repo.delete(book) do
      log_action(scope, :deleted, book)
      Books.broadcast_book(book.user_id, {:deleted, book})
      {:ok, book}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes in admin forms.

  ## Examples

      iex> change_book(book)
      %Ecto.Changeset{data: %Book{}}

  """
  def change_book(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end

  defp log_action(scope, action, %Book{} = book) do
    Logger.info("[admin] user #{scope.user.id} #{action} book #{book.id} (owner #{book.user_id})")
  end
end
