defmodule MyAppWeb.Live.PostLive do
  use Backpex.LiveResource,
    adapter_config: [
      schema: MyApp.Blog.Post,
      repo: MyApp.Repo,
      update_changeset: &MyApp.Blog.Post.update_changeset/3,
      create_changeset: &MyApp.Blog.Post.create_changeset/3
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
end
