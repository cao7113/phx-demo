defmodule MyAppWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use MyAppWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://phoenix.hexdocs.pm/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar px-4 sm:px-6 lg:px-8">
      <div class="flex-1">
        <a href="/" class="flex-1 flex w-fit items-center gap-2">
          <img src={~p"/images/logo.svg"} width="36" />
          <span class="text-sm font-semibold">v{Application.spec(:phoenix, :vsn)}</span>
        </a>
      </div>
      <div class="flex-none">
        <ul class="flex flex-column px-1 space-x-4 items-center">
          <li>
            <a href="https://phoenixframework.org/" class="btn btn-ghost">Website</a>
          </li>
          <li>
            <a href="https://github.com/phoenixframework/phoenix" class="btn btn-ghost">GitHub</a>
          </li>
          <li>
            <.theme_toggle />
          </li>
          <li>
            <a href="https://phoenix.hexdocs.pm/overview.html" class="btn btn-primary">
              Get Started <span aria-hidden="true">&rarr;</span>
            </a>
          </li>
        </ul>
      </div>
    </header>

    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 [[data-theme-source=system]_&]:!left-0 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end

  @doc """
  Admin layout
  """
  def admin(assigns) do
    ~H"""
    <div class="flex h-screen bg-base-200">
      <!-- Sidebar: resizable via the right-edge handle, collapsible via the toggle
           button; width and collapsed state persist in localStorage (AdminSidebar hook) -->
      <aside
        id="admin-sidebar"
        phx-hook="AdminSidebar"
        style="width: 16rem"
        class="bg-base-100 border-r border-base-300 flex flex-col shrink-0 relative"
      >
        <div class="sidebar-header h-16 flex items-center justify-between px-4 font-bold text-lg border-b border-base-300">
          <span class="sidebar-label">MyApp Admin</span>
          <button
            id="admin-sidebar-toggle"
            type="button"
            class="btn btn-ghost btn-sm"
            aria-label="Toggle sidebar"
          >
            <span class="sidebar-collapse-icon"><.icon name="hero-chevron-double-left" class="size-4" /></span>
            <span class="sidebar-expand-icon"><.icon name="hero-chevron-double-right" class="size-4" /></span>
          </button>
        </div>
        <nav class="flex-1 px-3 py-4 space-y-1">
          <.admin_nav_link navigate={~p"/admin"} icon="hero-chart-bar">Dashboard</.admin_nav_link>
          <.admin_nav_link navigate={~p"/admin/demo"} icon="hero-users">Demo</.admin_nav_link>
          <.admin_nav_link navigate={~p"/admin/users"} icon="hero-users">Users</.admin_nav_link>
          <.admin_nav_link navigate={~p"/admin/books"} icon="hero-book-open">Books</.admin_nav_link>
        </nav>
        <div class="sidebar-footer p-4 border-t border-base-300 text-sm">
          <.link
            href={~p"/"}
            class="flex items-center gap-1.5 text-base-content/60 hover:underline"
          >
            <.icon name="hero-arrow-left" class="size-4" />
            Back to site
          </.link>
          <p class="font-medium truncate mt-2">{@current_scope.user.email}</p>
          <.link
            href={~p"/users/log-out"}
            method="delete"
            class="text-base-content/60 hover:underline"
          >
            Log out
          </.link>
        </div>
        <div
          id="admin-sidebar-handle"
          class="absolute right-0 top-0 h-full w-1.5 cursor-col-resize bg-transparent hover:bg-primary/30"
          title="Drag to resize"
        ></div>
      </aside>

      <!-- Main -->
      <div class="flex-1 flex flex-col overflow-hidden">
        <header class="h-16 bg-base-100 border-b border-base-300 flex items-center px-6">
          <h1 class="text-xl font-semibold">{assigns[:page_title] || "Admin"}</h1>
        </header>
        <main class="flex-1 overflow-y-auto p-6">
          <.flash_group flash={@flash} />
          {@inner_content}
        </main>
      </div>
    </div>
    """
  end

  attr :navigate, :string, required: true
  attr :icon, :string, required: true
  slot :inner_block, required: true

  defp admin_nav_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class="admin-nav-link flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium text-base-content/80 hover:bg-base-200 hover:text-base-content transition-colors"
    >
      <.icon name={@icon} class="w-5 h-5 shrink-0" />
      <span class="sidebar-label">{render_slot(@inner_block)}</span>
    </.link>
    """
  end
end
