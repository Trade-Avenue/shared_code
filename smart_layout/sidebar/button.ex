defmodule FeedbackCupcakeWeb.Components.Sidebar.Button do
  @moduledoc false

  alias FeedbackCupcakeWeb.Components.Icon

  use FeedbackCupcakeWeb, :html

  attr :text, :string, required: true
  attr :to, :string, required: false
  attr :icon, :atom, required: false

  def render(assigns) do
    assigns =
      assigns
      |> assign_new(:to, fn -> nil end)
      |> assign_new(:icon, fn -> nil end)

    ~H"""
    <a
      :if={not is_nil(@to)}
      href={@to}
      class="flex items-center text-sm font-semibold leading-none px-3 py-2 gap-3 transition duration-200 w-full rounded-md group text-gray-700 hover:bg-gray-50 dark:text-gray-200 hover:text-gray-900 dark:hover:text-white dark:hover:bg-gray-700"
    >
      <.icon_text text={@text} icon={@icon} />
    </a>

    <div
      :if={is_nil(@to)}
      class="flex items-center text-sm font-semibold leading-none px-3 py-2 gap-3 transition duration-200 w-full rounded-md group text-gray-300 hover:bg-gray-50 hover:cursor-no-drop dark:text-gray-500 hover:text-gray-400 dark:hover:text-gray-500 dark:hover:bg-gray-700"
    >
      <.icon_text text={@text} icon={@icon} />
    </div>
    """
  end

  def icon_text(assigns) do
    ~H"""
    <%= if not is_nil(@icon) do %>
      <Icon.named name={@icon} class="w-5 h-5 flex-shrink-0" />
    <% end %>

    <div class="flex-1"><%= @text %></div>
    """
  end
end
