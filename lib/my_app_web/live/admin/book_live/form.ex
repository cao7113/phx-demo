defmodule MyAppWeb.Admin.BookLive.Form do
  use MyAppWeb, :live_view

  alias MyApp.Accounts.Admin, as: AccountsAdmin
  alias MyApp.Books.Admin
  alias MyApp.Books.Book

  @impl true
  def mount(params, _session, socket) do
    {:ok, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    book = %Book{}

    socket
    |> assign(:page_title, "New Book")
    |> assign(:book, book)
    |> assign(:form, to_form(Admin.change_book(book)))
    |> assign(:user_options, user_options())
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    book = Admin.get_book!(id)

    socket
    |> assign(:page_title, "Edit Book")
    |> assign(:book, book)
    |> assign(:form, to_form(Admin.change_book(book)))
    |> assign(:user_options, user_options())
  end

  defp user_options do
    AccountsAdmin.list_users()
    |> Enum.map(&{&1.email, &1.id})
  end

  @impl true
  def handle_event("validate", %{"book" => params}, socket) do
    changeset =
      socket.assigns.book
      |> Admin.change_book(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"book" => params}, socket) do
    save_book(socket, socket.assigns.live_action, params)
  end

  defp save_book(socket, :new, params) do
    case Admin.create_book(socket.assigns.current_scope, params) do
      {:ok, _book} ->
        {:noreply,
         socket
         |> put_flash(:info, "Book created.")
         |> push_navigate(to: ~p"/admin/books")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_book(socket, :edit, params) do
    case Admin.update_book(socket.assigns.current_scope, socket.assigns.book, params) do
      {:ok, _book} ->
        {:noreply,
         socket
         |> put_flash(:info, "Book updated.")
         |> push_navigate(to: ~p"/admin/books")}

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
        <:subtitle>Manage this book's details and owner.</:subtitle>
      </.header>

      <.form for={@form} id="book-form" phx-change="validate" phx-submit="save" class="space-y-6 mt-8">
        <.input field={@form[:title]} label="Title" />
        <.input field={@form[:note]} label="Note" type="textarea" />
        <.input
          field={@form[:user_id]}
          label="Owner"
          type="select"
          prompt="Select owner"
          options={@user_options}
        />

        <div class="flex items-center gap-4">
          <.button phx-disable-with="Saving…">Save Book</.button>
          <.link navigate={~p"/admin/books"} class="text-sm text-base-content/60 hover:underline">
            Cancel
          </.link>
        </div>
      </.form>
    </div>
    """
  end
end
