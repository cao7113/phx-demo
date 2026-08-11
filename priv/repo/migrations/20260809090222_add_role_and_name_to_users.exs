defmodule MyApp.Repo.Migrations.AddRoleAndNameToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string
      add :role, :string, default: "member", null: false
    end

    create index(:users, [:role])
  end
end
