defmodule MyApp.Books do
  @moduledoc """
  The Books context.
  """

  import Ecto.Query, warn: false
  alias MyApp.Repo

  alias MyApp.Books.Book
  alias MyApp.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any book changes.

  The broadcasted messages match the pattern:

    * {:created, %Book{}}
    * {:updated, %Book{}}
    * {:deleted, %Book{}}

  """
  def subscribe_books(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(MyApp.PubSub, "user:#{key}:books")
  end

  @doc """
  Broadcasts a book change to a user's channel.

  The messages match the pattern:

    * {:created, %Book{}}
    * {:updated, %Book{}}
    * {:deleted, %Book{}}

  The `user_id` is the book owner's id — the one whose public book pages
  should live-update. Used by `MyApp.Books` (scoped functions) and
  `MyApp.Books.Admin` (which acts on other users' books).
  """
  def broadcast_book(user_id, message) do
    Phoenix.PubSub.broadcast(MyApp.PubSub, "user:#{user_id}:books", message)
  end

  @doc """
  Returns the list of books.

  ## Examples

      iex> list_books(scope)
      [%Book{}, ...]

  """
  def list_books(%Scope{} = scope) do
    Repo.all_by(Book, user_id: scope.user.id)
  end

  @doc """
  Gets a single book.

  Raises `Ecto.NoResultsError` if the Book does not exist.

  ## Examples

      iex> get_book!(scope, 123)
      %Book{}

      iex> get_book!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_book!(%Scope{} = scope, id) do
    Repo.get_by!(Book, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a book.

  ## Examples

      iex> create_book(scope, %{field: value})
      {:ok, %Book{}}

      iex> create_book(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_book(%Scope{} = scope, attrs) do
    with {:ok, book = %Book{}} <-
           %Book{}
           |> Book.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_book(scope.user.id, {:created, book})
      {:ok, book}
    end
  end

  @doc """
  Updates a book.

  ## Examples

      iex> update_book(scope, book, %{field: new_value})
      {:ok, %Book{}}

      iex> update_book(scope, book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_book(%Scope{} = scope, %Book{} = book, attrs) do
    true = book.user_id == scope.user.id

    with {:ok, book = %Book{}} <-
           book
           |> Book.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_book(scope.user.id, {:updated, book})
      {:ok, book}
    end
  end

  @doc """
  Deletes a book.

  ## Examples

      iex> delete_book(scope, book)
      {:ok, %Book{}}

      iex> delete_book(scope, book)
      {:error, %Ecto.Changeset{}}

  """
  def delete_book(%Scope{} = scope, %Book{} = book) do
    true = book.user_id == scope.user.id

    with {:ok, book = %Book{}} <-
           Repo.delete(book) do
      broadcast_book(scope.user.id, {:deleted, book})
      {:ok, book}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(scope, book)
      %Ecto.Changeset{data: %Book{}}

  """
  def change_book(%Scope{} = scope, %Book{} = book, attrs \\ %{}) do
    true = book.user_id == scope.user.id

    Book.changeset(book, attrs, scope)
  end
end
