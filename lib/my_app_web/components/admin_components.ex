defmodule MyAppWeb.AdminComponents do
  @moduledoc "Reusable building blocks for admin pages. Uses the project's built-in daisyUI/Tailwind — no extra deps."
  use Phoenix.Component
  use MyAppWeb, :verified_routes
  import MyAppWeb.CoreComponents, only: [icon: 1]

  attr :label, :string, required: true
  attr :value, :string, required: true
  attr :delta, :string, default: nil
  attr :icon, :string, default: "hero-chart-bar"

  def stat_card(assigns) do
    ~H"""
    <div class="bg-base-100 rounded-xl border border-base-300 p-5">
      <div class="flex items-center justify-between">
        <span class="text-sm text-base-content/60">{@label}</span>
        <.icon name={@icon} class="w-5 h-5 text-base-content/40" />
      </div>
      <div class="mt-2 text-2xl font-bold">{@value}</div>
      <div :if={@delta} class="mt-1 text-xs text-success">{@delta}</div>
    </div>
    """
  end

  attr :field, :atom, required: true
  attr :label, :string, required: true
  attr :sort_by, :atom, required: true
  attr :sort_dir, :atom, required: true

  def sortable_th(assigns) do
    ~H"""
    <th
      phx-click="sort"
      phx-value-field={@field}
      class="px-4 py-3 text-left text-xs font-semibold uppercase text-base-content/60 cursor-pointer select-none hover:text-base-content"
    >
      <div class="flex items-center gap-1">
        {@label}
        <.icon
          :if={@sort_by == @field}
          name={if @sort_dir == :asc, do: "hero-chevron-up", else: "hero-chevron-down"}
          class="w-3 h-3"
        />
      </div>
    </th>
    """
  end

  attr :page, :integer, required: true
  attr :total_pages, :integer, required: true
  attr :event, :string, default: "paginate"

  def pagination(assigns) do
    ~H"""
    <div class="flex items-center justify-between px-4 py-3 border-t border-base-300 text-sm">
      <span class="text-base-content/60">Page {@page} of {@total_pages}</span>
      <div class="flex gap-2">
        <button
          phx-click={@event}
          phx-value-page={@page - 1}
          disabled={@page <= 1}
          class="btn btn-sm btn-ghost"
        >
          Previous
        </button>
        <button
          phx-click={@event}
          phx-value-page={@page + 1}
          disabled={@page >= @total_pages}
          class="btn btn-sm btn-ghost"
        >
          Next
        </button>
      </div>
    </div>
    """
  end
end
