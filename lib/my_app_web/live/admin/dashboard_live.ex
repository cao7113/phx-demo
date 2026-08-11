defmodule MyAppWeb.Admin.DashboardLive do
  use MyAppWeb, :live_view
  import MyAppWeb.AdminComponents

  alias MyApp.Accounts.Admin

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign(:stats, load_stats())
     |> assign(:recent_signups, Admin.list_recent_users(limit: 5))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <.stat_card label="Total Users" value={@stats.total_users} icon="hero-users" />
        <.stat_card label="Active Today" value={@stats.active_today} icon="hero-bolt" />
        <.stat_card label="Admins" value={@stats.admin_count} icon="hero-shield-check" />
      </div>

      <div class="bg-base-100 rounded-xl border border-base-300">
        <div class="px-4 py-3 border-b border-base-300 font-medium">Recent Signups</div>
        <ul class="divide-y divide-base-300">
          <li
            :for={user <- @recent_signups}
            class="px-4 py-3 flex items-center justify-between text-sm"
          >
            <span>{user.email}</span>
            <span class="text-base-content/50">{Calendar.strftime(user.inserted_at, "%b %d, %Y")}</span>
          </li>
          <li :if={@recent_signups == []} class="px-4 py-6 text-center text-base-content/50 text-sm">
            No users yet.
          </li>
        </ul>
      </div>
    </div>
    """
  end

  defp load_stats do
    %{
      total_users: Admin.count_users() |> to_string(),
      active_today: Admin.count_active_today() |> to_string(),
      admin_count: Admin.count_admins() |> to_string()
    }
  end
end
