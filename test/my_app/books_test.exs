defmodule MyApp.BooksTest do
  use MyApp.DataCase

  alias MyApp.Books

  describe "books" do
    alias MyApp.Books.Book

    import MyApp.AccountsFixtures, only: [user_scope_fixture: 0]
    import MyApp.BooksFixtures

    @invalid_attrs %{title: nil, note: nil}

    test "list_books/1 returns all scoped books" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      book = book_fixture(scope)
      other_book = book_fixture(other_scope)
      assert Books.list_books(scope) == [book]
      assert Books.list_books(other_scope) == [other_book]
    end

    test "get_book!/2 returns the book with given id" do
      scope = user_scope_fixture()
      book = book_fixture(scope)
      other_scope = user_scope_fixture()
      assert Books.get_book!(scope, book.id) == book
      assert_raise Ecto.NoResultsError, fn -> Books.get_book!(other_scope, book.id) end
    end

    test "create_book/2 with valid data creates a book" do
      valid_attrs = %{title: "some title", note: "some note"}
      scope = user_scope_fixture()

      assert {:ok, %Book{} = book} = Books.create_book(scope, valid_attrs)
      assert book.title == "some title"
      assert book.note == "some note"
      assert book.user_id == scope.user.id
    end

    test "create_book/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Books.create_book(scope, @invalid_attrs)
    end

    test "update_book/3 with valid data updates the book" do
      scope = user_scope_fixture()
      book = book_fixture(scope)
      update_attrs = %{title: "some updated title", note: "some updated note"}

      assert {:ok, %Book{} = book} = Books.update_book(scope, book, update_attrs)
      assert book.title == "some updated title"
      assert book.note == "some updated note"
    end

    test "update_book/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      book = book_fixture(scope)

      assert_raise MatchError, fn ->
        Books.update_book(other_scope, book, %{})
      end
    end

    test "update_book/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      book = book_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Books.update_book(scope, book, @invalid_attrs)
      assert book == Books.get_book!(scope, book.id)
    end

    test "delete_book/2 deletes the book" do
      scope = user_scope_fixture()
      book = book_fixture(scope)
      assert {:ok, %Book{}} = Books.delete_book(scope, book)
      assert_raise Ecto.NoResultsError, fn -> Books.get_book!(scope, book.id) end
    end

    test "delete_book/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      book = book_fixture(scope)
      assert_raise MatchError, fn -> Books.delete_book(other_scope, book) end
    end

    test "change_book/2 returns a book changeset" do
      scope = user_scope_fixture()
      book = book_fixture(scope)
      assert %Ecto.Changeset{} = Books.change_book(scope, book)
    end
  end
end
