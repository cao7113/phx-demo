defmodule MyApp.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "blog_posts" do
    field :title, :string
    field :views, :integer
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs, user_scope) do
    post
    |> base_changeset(attrs)
    |> put_change(:user_id, user_scope.user.id)
  end

  @doc false
  def create_changeset(post, attrs, _metadata), do: base_changeset(post, attrs)

  @doc false
  def update_changeset(post, attrs, _metadata), do: base_changeset(post, attrs)

  defp base_changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :views])
    |> validate_required([:title, :views])
  end
end
