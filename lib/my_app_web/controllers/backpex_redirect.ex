defmodule MyAppWeb.Backpex.RedirectController do
  use MyAppWeb, :controller

  def redirect_to_posts(conn, _params) do
    conn
    |> Phoenix.Controller.redirect(to: ~p"/backpex/posts")
    |> Plug.Conn.halt()
  end
end
