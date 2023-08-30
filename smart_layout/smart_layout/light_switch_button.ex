defmodule FeedbackCupcakeWeb.Components.SmartLayout.LightSwitchButton do
  @moduledoc false

  use FeedbackCupcakeWeb, :html

  attr :id, :string, required: true
  attr :light?, :boolean, default: true, doc: "Initial light"
  attr :ref_id, :string, default: ""

  def render(assigns) do
    ~H"""
    <.button
      phx-click={make_light(@ref_id, @id)}
      phx-mounted={@light? && make_light(@ref_id, @id)}
      id={"dark-button-#{@id}"}
      type="button"
      class="color-scheme text-gray-400 bg-transparent hover:bg-gray-700 focus:outline-none focus:ring-4 focus:ring-gray-700 rounded-lg text-sm p-2.5"
    >
      <Heroicons.sun solid class="w-5" />
    </.button>

    <.button
      phx-click={make_dark(@ref_id, @id)}
      phx-mounted={!@light? && make_dark(@ref_id, @id)}
      id={"light-button-#{@id}"}
      type="button"
      class="color-scheme text-gray-500 bg-transparent dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700 focus:outline-none focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-700 rounded-lg text-sm p-2.5 dark:hidden"
    >
      <Heroicons.sun solid class="w-5" />
    </.button>
    """
  end

  defp make_dark(js \\ %JS{}, ref_id, id) do
    js
    |> JS.hide()
    |> JS.show(to: "#dark-button-#{id}")
    |> JS.add_class("dark", to: "##{ref_id}")
  end

  defp make_light(js \\ %JS{}, ref_id, id) do
    js
    |> JS.hide()
    |> JS.show(to: "#light-button-#{id}")
    |> JS.remove_class("dark", to: "##{ref_id}")
  end
end
