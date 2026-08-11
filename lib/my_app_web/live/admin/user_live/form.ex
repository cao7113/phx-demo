defmodule MyAppWeb.Admin.UserLive.Form do
  use MyAppWeb, :live_view

  alias MyApp.Accounts
  alias MyApp.Accounts.Admin
  alias MyApp.Accounts.User

  @impl true
  def mount(params, _session, socket) do
    {:ok, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    user = %User{}

    socket
    |> assign(:page_title, "New User")
    |> assign(:user, user)
    |> assign(:form, to_form(Admin.change_user(user)))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    user = Accounts.get_user!(id)

    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, user)
    |> assign(:form, to_form(Admin.change_user(user)))
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      socket.assigns.user
      |> Admin.change_user(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"user" => params}, socket) do
    save_user(socket, socket.assigns.live_action, params)
  end

  defp save_user(socket, :new, params) do
    case Admin.create_user(socket.assigns.current_scope, params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User created.")
         |> push_navigate(to: ~p"/admin/users")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_user(socket, :edit, params) do
    case Admin.update_user(socket.assigns.current_scope, socket.assigns.user, params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User updated.")
         |> push_navigate(to: ~p"/admin/users")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-xl">
      <.header>
        {@page_title}
        <:subtitle>Manage this user's profile and role.</:subtitle>
      </.header>

      <.form for={@form} id="user-form" phx-change="validate" phx-submit="save" class="space-y-6 mt-8">
        <.input field={@form[:name]} label="Name" />
        <.input field={@form[:email]} label="Email" type="email" />
        <.input
          field={@form[:role]}
          label="Role"
          type="select"
          options={[Admin: "admin", Member: "member"]}
        />

        <div class="flex items-center gap-4">
          <.button phx-disable-with="Saving…">Save User</.button>
          <.link navigate={~p"/admin/users"} class="text-sm text-base-content/60 hover:underline">
            Cancel
          </.link>
        </div>
      </.form>
    </div>
    """
  end
end
