defmodule MyAppWeb.Live.PostLive do
  use Backpex.LiveResource,
    adapter_config: [
      schema: MyApp.Blog.Post,
      repo: MyApp.Repo,
      update_changeset: &__MODULE__.update_changeset/3,
      create_changeset: &__MODULE__.create_changeset/3
    ]

  @impl Backpex.LiveResource
  def layout(_assigns), do: {MyAppWeb.Layouts, :backpex}

  @impl Backpex.LiveResource
  def singular_name, do: "Post"

  @impl Backpex.LiveResource
  def plural_name, do: "Posts"

  @impl Backpex.LiveResource
  def fields do
    [
      title: %{
        module: Backpex.Fields.Text,
        label: "Title"
      },
      views: %{
        module: Backpex.Fields.Number,
        label: "Views"
      }
    ]
  end

  @doc false
  def create_changeset(post, attrs, _metadata), do: changeset(post, attrs)

  @doc false
  def update_changeset(post, attrs, _metadata), do: changeset(post, attrs)

  defp changeset(post, attrs) do
    post
    |> Ecto.Changeset.cast(attrs, [:title, :views])
    |> Ecto.Changeset.validate_required([:title, :views])
  end
end
