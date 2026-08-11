defmodule MyApp.Accounts.Admin do
  @moduledoc """
  Privileged operations on users for the admin area.

  These functions manage arbitrary user accounts — including roles and
  deletion — without the confirmation-email flow used by public
  registration. The `%Scope{}` argument of the mutating functions is the
  *acting* admin — carried for logging and audit only, never used for
  authorization.

  Keep this module out of public-facing code paths — only the admin live
  views should call into it.
  """

  require Logger

  import Ecto.Query, warn: false

  alias MyApp.Accounts.Scope
  alias MyApp.Accounts.User
  alias MyApp.Repo

  @doc """
  Paginated, searchable list of all users.

  ## Examples

      iex> paginate_users(search: "alice", sort_by: :name, page: 1, per_page: 20)
      %{entries: [%User{}], total_pages: 1, total_count: 1}

  """
  def paginate_users(opts \\ []) do
    search = Keyword.get(opts, :search, "")
    sort_by = Keyword.get(opts, :sort_by, :inserted_at)
    sort_dir = Keyword.get(opts, :sort_dir, :desc)
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)

    base_query =
      from u in User,
        where: ilike(u.email, ^"%#{search}%") or ilike(u.name, ^"%#{search}%")

    total_count = Repo.aggregate(base_query, :count, :id)
    total_pages = max(ceil(total_count / per_page), 1)

    entries =
      base_query
      |> order_by([u], [{^sort_dir, field(u, ^sort_by)}])
      |> limit(^per_page)
      |> offset(^((page - 1) * per_page))
      |> Repo.all()

    %{entries: entries, total_pages: total_pages, total_count: total_count}
  end

  @doc "Total user count for the dashboard KPI."
  def count_users, do: Repo.aggregate(User, :count, :id)

  @doc "How many users have the :admin role."
  def count_admins, do: Repo.aggregate(from(u in User, where: u.role == :admin), :count, :id)

  @doc "Users active in the last 24h, based on confirmed_at as a stand-in
      for last-seen; swap in a real `last_active_at` column if you track one."
  def count_active_today do
    since = DateTime.add(DateTime.utc_now(), -1, :day)
    Repo.aggregate(from(u in User, where: u.updated_at >= ^since), :count, :id)
  end

  @doc "Most recently registered users for the dashboard feed."
  def list_recent_users(opts \\ []) do
    limit = Keyword.get(opts, :limit, 5)

    User
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc "All users ordered by email, for admin selects (e.g. book owner)."
  def list_users do
    User
    |> order_by(asc: :email)
    |> Repo.all()
  end

  @doc """
  Creates a user directly (no confirmation email flow) as the given admin.

  ## Examples

      iex> create_user(scope, %{field: value})
      {:ok, %User{}}

      iex> create_user(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(%Scope{} = scope, attrs) do
    with {:ok, user = %User{}} <-
           %User{}
           |> User.admin_changeset(attrs)
           |> Repo.insert() do
      log_action(scope, :created, user)
      {:ok, user}
    end
  end

  @doc """
  Updates a user's profile fields (name/email/role) as the given admin.

  ## Examples

      iex> update_user(scope, user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(scope, user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%Scope{} = scope, %User{} = user, attrs) do
    with {:ok, user = %User{}} <-
           user
           |> User.admin_changeset(attrs)
           |> Repo.update() do
      log_action(scope, :updated, user)
      {:ok, user}
    end
  end

  @doc "Deletes a user as the given admin."
  def delete_user(%Scope{} = scope, %User{} = user) do
    with {:ok, user = %User{}} <-
           Repo.delete(user) do
      log_action(scope, :deleted, user)
      {:ok, user}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes in admin forms.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.admin_changeset(user, attrs)
  end

  defp log_action(scope, action, %User{} = user) do
    Logger.info("[admin] user #{scope.user.id} #{action} user #{user.id}")
  end
end
