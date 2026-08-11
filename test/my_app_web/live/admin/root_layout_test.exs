defmodule MyAppWeb.Admin.RootLayoutTest do
  use MyAppWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias MyApp.Accounts.Admin

  # The "Settings" link only exists in the public nav <ul> of the root
  # layout — the admin sidebar has its own "Log out" but no Settings link —
  # so it is a reliable marker for whether the <ul> was rendered.

  setup :register_and_log_in_user

  test "shows the nav menu on a controller-rendered page", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Settings"
    assert html_response(conn, 200) =~ "Log out"
  end

  test "shows the nav menu on a public live view", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/books")
    assert html =~ "Settings"
    assert html =~ "Log out"
  end

  test "hides the nav menu on an admin live view", %{conn: conn, user: user, scope: scope} do
    # the fixture user has no name, but admin_changeset requires one
    {:ok, _user} = Admin.update_user(scope, user, %{name: "Admin", role: "admin"})

    {:ok, _view, html} = live(conn, "/admin/users")
    refute html =~ "Settings"
    # the admin sidebar still renders its own logout link
    assert html =~ "Log out"
  end

  test "shows an Admin entry point to admin users on public pages", %{
    conn: conn,
    user: user,
    scope: scope
  } do
    {:ok, _user} = Admin.update_user(scope, user, %{name: "Admin", role: "admin"})

    {:ok, _view, html} = live(conn, "/books")
    assert html =~ "Admin"
    assert html =~ "Settings"
  end

  test "hides the Admin entry point from regular users on public pages", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/books")
    refute html =~ "Admin"
    assert html =~ "Settings"
  end

  test "shows a link back to the site on admin pages", %{conn: conn, user: user, scope: scope} do
    {:ok, _user} = Admin.update_user(scope, user, %{name: "Admin", role: "admin"})

    {:ok, _view, html} = live(conn, "/admin/users")
    assert html =~ "Back to site"
  end
end
