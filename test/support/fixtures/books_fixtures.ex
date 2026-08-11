defmodule MyApp.BooksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MyApp.Books` context.
  """

  @doc """
  Generate a book.
  """
  def book_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        note: "some note",
        title: "some title"
      })

    {:ok, book} = MyApp.Books.create_book(scope, attrs)
    book
  end
end
