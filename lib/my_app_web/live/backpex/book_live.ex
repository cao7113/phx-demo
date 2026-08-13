defmodule MyAppWeb.Live.BookLive do
  use Backpex.LiveResource,
    adapter_config: [
      schema: MyApp.Books.Book,
      repo: MyApp.Repo,
      update_changeset: &__MODULE__.update_changeset/3,
      create_changeset: &__MODULE__.create_changeset/3
    ]

  @impl Backpex.LiveResource
  def layout(_assigns), do: {MyAppWeb.Layouts, :backpex}

  @impl Backpex.LiveResource
  def singular_name, do: "Book"

  @impl Backpex.LiveResource
  def plural_name, do: "Books"

  @impl Backpex.LiveResource
  def fields do
    [
      title: %{
        module: Backpex.Fields.Text,
        label: "Title"
      },
      note: %{
        module: Backpex.Fields.Textarea,
        label: "Note"
      }
    ]
  end

  @doc false
  def create_changeset(book, attrs, _metadata), do: changeset(book, attrs)

  @doc false
  def update_changeset(book, attrs, _metadata), do: changeset(book, attrs)

  defp changeset(book, attrs) do
    book
    |> Ecto.Changeset.cast(attrs, [:title, :note])
    |> Ecto.Changeset.validate_required([:title, :note])
  end
end
