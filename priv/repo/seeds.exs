# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MyApp.Repo.insert!(%MyApp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias MyApp.{Accounts, Repo}

case Accounts.get_user_by_email("admin@dev.l") do
  nil ->
    {:ok, user} =
      %MyApp.Accounts.User{}
      |> MyApp.Accounts.User.admin_changeset(%{
        email: "admin@dev.l",
        name: "Admin",
        role: :admin
      })
      |> Repo.insert()

    user

  user ->
    user
end
|> Ecto.Changeset.change(role: :admin)
|> Repo.update!()
