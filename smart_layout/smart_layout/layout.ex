defmodule FeedbackCupcakeWeb.Components.SmartLayout.Layout do
  @moduledoc false

  use FeedbackCupcakeWeb, :html

  attr :id, :string, required: true

  slot :sidebar, doc: "left area, space to menu"
  slot :header, doc: "top area, space to header"
  slot :logo, doc: "top-left area, space to logo, often image and text"
  slot :avatar, doc: "top-right area, space to avatar button, but can add more"
  slot :body, doc: "bot-right area, body space"

  def render(assigns) do
    assigns =
      assigns
      |> assign_new(:sidebar, fn -> [] end)
      |> assign_new(:header, fn -> [] end)
      |> assign_new(:logo, fn -> [] end)
      |> assign_new(:avatar, fn -> [] end)
      |> assign_new(:body, fn -> [] end)

    ~H"""
    <div class="flex h-screen overflow-hidden dark:bg-gray-900">
      <div class="relative z-40 lg:w-64">
        <div
          id={"sidebar-container-#{@id}"}
          class="fixed inset-0 bg-gray-900/80 hidden"
          phx-click={hide_sidbebar(@id)}
        />

        <div
          id={"sidebar-#{@id}"}
          class="absolute top-0 left-0 z-40 flex-shrink-0 w-64 h-screen p-4 overflow-y-auto transition-transform duration-200 ease-in-out transform border-r lg:static lg:left-auto lg:top-auto lg:translate-x-0 lg:overflow-y-auto no-scrollbar bg-white dark:bg-gray-900 border-gray-200 dark:border-gray-700  hidden lg:block"
        >
          <div class="flex justify-between pr-3 mb-10 sm:px-2">
            <.back_button id={@id} />

            <%= render_slot(@logo) %>
          </div>

          <div>
            <%= render_slot(@sidebar) %>
          </div>
        </div>
      </div>
      <div class="relative flex flex-col flex-1 pb-32 overflow-x-auto overflow-y-auto lg:pb-0">
        <header class="sticky top-0 z-30 border-b dark:lg:shadow-none dark:border-b lg:backdrop-filter backdrop-blur bg-white dark:bg-gray-900 border-gray-200 dark:border-gray-700">
          <div class="px-4 sm:px-6 lg:px-8">
            <div class="flex items-center justify-between h-16 -mb-px">
              <div class="flex min-w-[68px]">
                <.sidebar_button id={@id} />
              </div>

              <%= render_slot(@header) %>

              <div class="flex items-center gap-3">
                <%= render_slot(@avatar) %>
              </div>
            </div>
          </div>
        </header>

        <div class="h-full pc-container  pc-container--mobile-padded">
          <%= render_slot(@body) %>
        </div>
      </div>
    </div>
    """
  end

  defp back_button(assigns) do
    ~H"""
    <button class="text-gray-500 lg:hidden hover:text-gray-400" phx-click={hide_sidbebar(@id)}>
      <Heroicons.arrow_left solid class="w-6 h-6 fill-current" />
    </button>
    """
  end

  defp sidebar_button(assigns) do
    ~H"""
    <button class="text-gray-500 hover:text-gray-600 lg:hidden" phx-click={show_sidbebar(@id)}>
      <Heroicons.bars_3 solid class="w-6 h-6 fill-current" />
    </button>
    """
  end

  defp show_sidbebar(js \\ %JS{}, id) do
    js
    |> JS.remove_class("hidden", to: "#sidebar-#{id}")
    |> JS.remove_class("hidden", to: "#sidebar-container-#{id}")
  end

  defp hide_sidbebar(js \\ %JS{}, id) do
    js
    |> JS.add_class("hidden", to: "#sidebar-#{id}")
    |> JS.add_class("hidden", to: "#sidebar-container-#{id}")
  end
end
