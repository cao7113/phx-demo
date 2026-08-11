defmodule MyAppWeb.Admin.UserLive.Index do
  use MyAppWeb, :live_view
  import MyAppWeb.AdminComponents, only: [pagination: 1]

  alias MyApp.Accounts
  alias MyApp.Accounts.Admin

  @per_page 20

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Users")
     |> assign(:search, "")
     |> assign(:sort, "inserted_at:desc")
     |> assign(:page, 1)
     |> reload_users()}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    {:noreply, socket |> assign(search: query, page: 1) |> reload_users()}
  end

  def handle_event("sort", %{"sort" => sort}, socket) do
    {:noreply, socket |> assign(sort: sort, page: 1) |> reload_users()}
  end

  def handle_event("paginate", %{"page" => page}, socket) do
    {:noreply, socket |> assign(:page, String.to_integer(page)) |> reload_users()}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    if id == to_string(socket.assigns.current_scope.user.id) do
      {:noreply, put_flash(socket, :error, "You can't delete your own account.")}
    else
      user = Accounts.get_user!(id)
      {:ok, _} = Admin.delete_user(socket.assigns.current_scope, user)

      {:noreply,
       socket
       |> put_flash(:info, "User deleted.")
       |> stream_delete(:users, user)}
    end
  end

  defp reload_users(socket) do
    %{search: search, sort: sort, page: page} = socket.assigns
    [field, dir] = String.split(sort, ":")

    %{entries: users, total_pages: total_pages} =
      Admin.paginate_users(
        search: search,
        sort_by: String.to_existing_atom(field),
        sort_dir: String.to_existing_atom(dir),
        page: page,
        per_page: @per_page
      )

    socket
    |> assign(:total_pages, total_pages)
    |> stream(:users, users, reset: true)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <.header>
        Users
        <:actions>
          <.link navigate={~p"/admin/users/new"} class="btn btn-primary">
            <.icon name="hero-plus" class="w-4 h-4" /> New User
          </.link>
        </:actions>
      </.header>

      <div class="flex items-center gap-3">
        <form phx-change="search" class="w-72">
          <input
            type="text"
            name="q"
            value={@search}
            placeholder="Search by name or email…"
            class="input input-bordered w-full"
          />
        </form>

        <form phx-change="sort">
          <select name="sort" class="select select-bordered">
            <option value="inserted_at:desc" selected={@sort == "inserted_at:desc"}>
              Newest first
            </option>
            <option value="inserted_at:asc" selected={@sort == "inserted_at:asc"}>
              Oldest first
            </option>
            <option value="name:asc" selected={@sort == "name:asc"}>Name A–Z</option>
            <option value="name:desc" selected={@sort == "name:desc"}>Name Z–A</option>
            <option value="role:asc" selected={@sort == "role:asc"}>Role</option>
          </select>
        </form>
      </div>

      <div class="bg-base-100 rounded-xl border border-base-300 overflow-hidden">
        <.table id="users" rows={@streams.users}>
          <:col :let={{_id, user}} label="Name">{user.name}</:col>
          <:col :let={{_id, user}} label="Email">{user.email}</:col>
          <:col :let={{_id, user}} label="Role">
            <span class={["badge", user.role == :admin && "badge-primary"]}>{user.role}</span>
          </:col>
          <:col :let={{_id, user}} label="Joined">
            {Calendar.strftime(user.inserted_at, "%b %d, %Y")}
          </:col>
          <:action :let={{_id, user}}>
            <.link navigate={~p"/admin/users/#{user.id}/edit"} class="btn btn-xs btn-ghost">Edit</.link>
          </:action>
          <:action :let={{id, user}}>
            <button
              phx-click={JS.push("delete", value: %{id: user.id}) |> hide("##{id}")}
              data-confirm="Are you sure?"
              class="btn btn-xs btn-ghost text-error"
            >
              Delete
            </button>
          </:action>
        </.table>
        <.pagination page={@page} total_pages={@total_pages} />
      </div>
    </div>
    """
  end
end
