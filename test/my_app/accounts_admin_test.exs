defmodule MyApp.Accounts.AdminTest do
  use MyApp.DataCase

  alias MyApp.Accounts
  alias MyApp.Accounts.Admin
  alias MyApp.Accounts.User

  import MyApp.AccountsFixtures

  describe "paginate_users/1" do
    test "returns all users, newest first by default" do
      user = user_fixture()
      other_user = user_fixture()

      # inserted_at is second-granularity, so pin distinct timestamps
      # to make the ordering deterministic
      user |> Ecto.Changeset.change(inserted_at: ~U[2024-01-01 00:00:00Z]) |> MyApp.Repo.update!()

      other_user
      |> Ecto.Changeset.change(inserted_at: ~U[2024-01-02 00:00:00Z])
      |> MyApp.Repo.update!()

      assert %{entries: entries, total_pages: 1, total_count: 2} = Admin.paginate_users()
      assert Enum.map(entries, & &1.id) == [other_user.id, user.id]
    end

    test "search filters by email or name" do
      admin_scope = user_scope_fixture()

      # user_fixture drops `name` (registration changeset only casts
      # email/password), so create users through the admin API here
      assert {:ok, _} =
               Admin.create_user(admin_scope, %{
                 name: "Alice",
                 email: "alice@example.com",
                 role: "member"
               })

      assert {:ok, _} =
               Admin.create_user(admin_scope, %{
                 name: "Bobby",
                 email: "bob@example.com",
                 role: "member"
               })

      assert %{entries: [%{name: "Alice"}]} = Admin.paginate_users(search: "alice")
      assert %{entries: [%{name: "Bobby"}]} = Admin.paginate_users(search: "Bobby")
    end

    test "sorts by name and paginates" do
      admin_scope = user_scope_fixture()

      # the fixture user has a nil name; rename it so it participates
      # in the ordering instead of landing in the NULLS LAST bucket
      {:ok, admin} = Admin.update_user(admin_scope, admin_scope.user, %{name: "Z"})
      admin_scope = user_scope_fixture(admin)

      for name <- ["A", "B", "C"] do
        assert {:ok, _} =
                 Admin.create_user(admin_scope, %{
                   name: name,
                   email: unique_user_email(),
                   role: "member"
                 })
      end

      assert %{entries: [%{name: "A"}, %{name: "B"}], total_pages: 2} =
               Admin.paginate_users(sort_by: :name, sort_dir: :asc, page: 1, per_page: 2)

      assert %{entries: [%{name: "C"}, %{name: "Z"}]} =
               Admin.paginate_users(sort_by: :name, sort_dir: :asc, page: 2, per_page: 2)
    end
  end

  describe "create_user/2" do
    test "creates a user with a role as the given admin" do
      admin_scope = user_scope_fixture()

      assert {:ok, %User{} = user} =
               Admin.create_user(admin_scope, %{
                 name: "Alice",
                 email: unique_user_email(),
                 role: "admin"
               })

      assert user.name == "Alice"
      assert user.role == :admin
      assert user.confirmed_at == nil
    end

    test "with missing required fields returns error changeset" do
      admin_scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Admin.create_user(admin_scope, %{name: nil})
    end

    test "rejects a duplicate email" do
      admin_scope = user_scope_fixture()
      user = user_fixture()

      assert {:error, changeset} =
               Admin.create_user(admin_scope, %{name: "Dup", email: user.email, role: "member"})

      assert "has already been taken" in errors_on(changeset).email
    end
  end

  describe "update_user/3" do
    test "updates profile fields and role" do
      admin_scope = user_scope_fixture()
      user = user_fixture()

      assert {:ok, %User{} = updated} =
               Admin.update_user(admin_scope, user, %{name: "Renamed", role: "admin"})

      assert updated.name == "Renamed"
      assert updated.role == :admin
    end

    test "with invalid data returns error changeset" do
      admin_scope = user_scope_fixture()
      user = user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Admin.update_user(admin_scope, user, %{email: nil})
    end
  end

  describe "delete_user/2" do
    test "deletes the user" do
      admin_scope = user_scope_fixture()
      user = user_fixture()

      assert {:ok, %User{}} = Admin.delete_user(admin_scope, user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end
  end

  describe "dashboard counters" do
    test "counts users, admins and active today" do
      user_fixture()
      admin_scope = user_scope_fixture()

      assert {:ok, %User{role: :admin}} =
               Admin.create_user(admin_scope, %{
                 name: "Boss",
                 email: unique_user_email(),
                 role: "admin"
               })

      assert Admin.count_users() >= 3
      assert Admin.count_admins() >= 1
      assert Admin.count_active_today() >= 3
    end
  end

  describe "list_recent_users/1" do
    test "returns most recent users first" do
      user = user_fixture()
      other_user = user_fixture()

      # inserted_at is second-granularity, so pin distinct timestamps
      user |> Ecto.Changeset.change(inserted_at: ~U[2024-01-01 00:00:00Z]) |> MyApp.Repo.update!()

      other_user
      |> Ecto.Changeset.change(inserted_at: ~U[2024-01-02 00:00:00Z])
      |> MyApp.Repo.update!()

      assert Enum.map(Admin.list_recent_users(limit: 1), & &1.id) == [other_user.id]
    end
  end

  describe "list_users/0" do
    test "returns all users ordered by email" do
      first = user_fixture(%{email: "aaa@example.com"})
      last = user_fixture(%{email: "zzz@example.com"})

      assert Enum.map(Admin.list_users(), & &1.id) == [first.id, last.id]
    end
  end

  describe "change_user/1" do
    test "returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Admin.change_user(user)
    end
  end
end
