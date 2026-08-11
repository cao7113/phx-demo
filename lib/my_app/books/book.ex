defmodule MyApp.Books.Book do
  use Ecto.Schema
  import Ecto.Changeset

  schema "books" do
    field :title, :string
    field :note, :string
    field :user_id, :id
    belongs_to :user, MyApp.Accounts.User, define_field: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(book, attrs, user_scope) do
    book
    |> cast(attrs, [:title, :note])
    |> validate_required([:title, :note])
    |> put_change(:user_id, user_scope.user.id)
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:title, :note, :user_id])
    |> validate_required([:title, :note, :user_id])
  end
end
