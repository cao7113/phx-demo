defmodule MyApp.Repo.Migrations.CreateBlogPosts do
  use Ecto.Migration

  def change do
    create table(:blog_posts) do
      add :title, :string
      add :views, :integer
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:blog_posts, [:user_id])
  end
end
