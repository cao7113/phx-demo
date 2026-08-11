defmodule MyAppWeb.Admin.AdminAuthTest do
  use ExUnit.Case, async: true

  alias MyAppWeb.Admin.AdminAuth

  describe "admin_path?/1" do
    test "true for a live view socket under /admin" do
      socket = %Phoenix.LiveView.Socket{
        private: %{connect_info: %{uri: %URI{path: "/admin/books"}}}
      }

      assert AdminAuth.admin_path?(%{socket: socket})
    end

    test "false for a public live view socket" do
      socket = %Phoenix.LiveView.Socket{
        private: %{connect_info: %{uri: %URI{path: "/books"}}}
      }

      refute AdminAuth.admin_path?(%{socket: socket})
    end

    test "true for a controller-rendered request under /admin" do
      conn = %Plug.Conn{request_path: "/admin/users"}
      assert AdminAuth.admin_path?(%{conn: conn})
    end

    test "false for a public controller-rendered request" do
      conn = %Plug.Conn{request_path: "/"}
      refute AdminAuth.admin_path?(%{conn: conn})
    end

    test "false when the path cannot be determined" do
      refute AdminAuth.admin_path?(%{})
      refute AdminAuth.admin_path?(%{conn: %Plug.Conn{request_path: nil}})
    end
  end
end
