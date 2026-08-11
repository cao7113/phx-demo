defmodule MyAppWeb.Admin.AdminAuth do
  @moduledoc """
  Admin-only guard, layered on top of the `current_scope` that
  mix phx.gen.auth already sets up. Use together with the existing
  :require_authenticated_user pipeline / :require_authenticated on_mount —
  this module only adds the extra "is this user an admin" check.
  """
  import Plug.Conn

  ## Plug — for regular controller-based admin routes, if you add any.
  def require_admin_user(conn, _opts) do
    if admin?(conn.assigns[:current_scope]) do
      conn
    else
      conn
      |> Phoenix.Controller.put_flash(:error, "You must be an admin to access this page.")
      |> Phoenix.Controller.redirect(to: "/")
      |> halt()
    end
  end

  ## on_mount — for the /admin live_session.
  def on_mount(:require_admin, _params, _session, socket) do
    if admin?(socket.assigns[:current_scope]) do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must be an admin to access this page.")
        |> Phoenix.LiveView.redirect(to: "/")

      {:halt, socket}
    end
  end

  def admin?(%MyApp.Accounts.Scope{user: %MyApp.Accounts.User{role: :admin}}), do: true
  def admin?(_), do: false

  @doc """
  Returns true when the current request is part of the /admin section.

  Used by the root layout, which wraps both public pages and the /admin
  section and so cannot know the current URL directly. Live views expose
  it via the socket's connect info URI (`:uri` must be listed in the
  socket's connect_info, see `MyAppWeb.Endpoint`); controller-rendered
  pages (e.g. the home page) via the request path. Returns false when
  the path is unknown.
  """
  def admin_path?(assigns) do
    path =
      case assigns[:socket] && Phoenix.LiveView.get_connect_info(assigns[:socket], :uri) do
        %URI{path: path} -> path
        _ -> assigns[:conn] && assigns[:conn].request_path
      end

    is_binary(path) and String.starts_with?(path, "/admin")
  end
end
