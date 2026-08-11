defmodule MyApp.Books.AdminTest do
  use MyApp.DataCase

  alias MyApp.Books
  alias MyApp.Books.Admin
  alias MyApp.Books.Book

  import MyApp.AccountsFixtures, only: [user_scope_fixture: 0]
  import MyApp.BooksFixtures

  describe "paginate_books/1" do
    test "returns all books across scopes, newest first by default" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      book = book_fixture(scope)
      other_book = book_fixture(other_scope)

      # inserted_at is second-granularity, so pin distinct timestamps
      # to make the ordering deterministic
      book |> Ecto.Changeset.change(inserted_at: ~U[2024-01-01 00:00:00Z]) |> MyApp.Repo.update!()
      other_book |> Ecto.Changeset.change(inserted_at: ~U[2024-01-02 00:00:00Z]) |> MyApp.Repo.update!()

      assert %{entries: entries, total_pages: 1, total_count: 2} = Admin.paginate_books()
      assert Enum.map(entries, & &1.id) == [other_book.id, book.id]
    end

    test "search filters by title or note" do
      scope = user_scope_fixture()
      book_fixture(scope, %{title: "Elixir in Action", note: "concurrency"})
      book_fixture(scope, %{title: "Other", note: "phoenix notes"})

      assert %{entries: [%{title: "Elixir in Action"}]} = Admin.paginate_books(search: "elixir")
      assert %{entries: [%{note: "phoenix notes"}]} = Admin.paginate_books(search: "phoenix")
    end

    test "sorts by title and paginates" do
      scope = user_scope_fixture()
      book_fixture(scope, %{title: "A"})
      book_fixture(scope, %{title: "B"})
      book_fixture(scope, %{title: "C"})

      assert %{entries: [%{title: "A"}, %{title: "B"}], total_pages: 2} =
               Admin.paginate_books(sort_by: :title, sort_dir: :asc, page: 1, per_page: 2)

      assert %{entries: [%{title: "C"}]} =
               Admin.paginate_books(sort_by: :title, sort_dir: :asc, page: 2, per_page: 2)
    end

    test "preloads the owner user" do
      scope = user_scope_fixture()
      book_fixture(scope)

      assert %{entries: [%{user: %{id: user_id}}]} = Admin.paginate_books()
      assert user_id == scope.user.id
    end
  end

  describe "create_book/2" do
    test "creates a book for the given owner" do
      admin_scope = user_scope_fixture()
      owner = user_scope_fixture()

      assert {:ok, %Book{} = book} =
               Admin.create_book(admin_scope, %{title: "some title", note: "some note", user_id: owner.user.id})

      assert book.title == "some title"
      assert book.note == "some note"
      assert book.user_id == owner.user.id
    end

    test "with missing owner returns error changeset" do
      admin_scope = user_scope_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Admin.create_book(admin_scope, %{title: "some title", note: "some note"})
    end

    test "broadcasts to the owner's channel" do
      admin_scope = user_scope_fixture()
      owner = user_scope_fixture()
      Phoenix.PubSub.subscribe(MyApp.PubSub, "user:#{owner.user.id}:books")

      assert {:ok, %Book{} = book} =
               Admin.create_book(admin_scope, %{title: "some title", note: "some note", user_id: owner.user.id})

      assert_receive {:created, ^book}
    end
  end

  describe "update_book/3" do
    test "updates any book, including changing its owner" do
      admin_scope = user_scope_fixture()
      book = book_fixture(user_scope_fixture())
      new_owner = user_scope_fixture()

      assert {:ok, %Book{} = updated} =
               Admin.update_book(admin_scope, book, %{title: "updated", user_id: new_owner.user.id})

      assert updated.title == "updated"
      assert updated.user_id == new_owner.user.id
    end

    test "with invalid data returns error changeset" do
      admin_scope = user_scope_fixture()
      book = book_fixture(user_scope_fixture())

      assert {:error, %Ecto.Changeset{}} =
               Admin.update_book(admin_scope, book, %{title: nil, note: nil})
    end
  end

  describe "delete_book/2" do
    test "deletes any book regardless of owner" do
      admin_scope = user_scope_fixture()
      owner_scope = user_scope_fixture()
      book = book_fixture(owner_scope)

      assert {:ok, %Book{}} = Admin.delete_book(admin_scope, book)
      assert_raise Ecto.NoResultsError, fn -> Books.get_book!(owner_scope, book.id) end
    end
  end

  describe "change_book/1" do
    test "returns a book changeset" do
      book = book_fixture(user_scope_fixture())
      assert %Ecto.Changeset{} = Admin.change_book(book)
    end
  end
end
