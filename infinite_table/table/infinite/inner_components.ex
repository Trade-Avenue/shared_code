defmodule FeedbackCupcakeWeb.Components.Table.Infinite.InnerComponents do
  @moduledoc false

  alias FeedbackCupcakeWeb.Components.Loading

  alias Phoenix.LiveView.JS

  use FeedbackCupcakeWeb, :html

  attr :id, :any, required: true, doc: "The parent component unique id."

  attr :tbody_id, :any, required: true, doc: "The table tbody unique id."

  def go_to_top_button(assigns) do
    ~H"""
    <.icon_button
      id={"#{@id}-go-to-top-button"}
      tooltip="Go to the top"
      size="xs"
      class="absolute bottom-0 right-0 mr-3 mb-3 bg-gray-200 hidden"
      phx-click={JS.dispatch("go_to_top", to: @tbody_id)}
    >
      <Heroicons.arrow_small_up solid />
    </.icon_button>
    """
  end

  attr :id, :any, required: true, doc: "The parent component unique id."

  def top_loading(assigns) do
    ~H"""
    <tbody class="border-none">
      <.tr class="relative">
        <.td
          id={"#{@id}-top-loading-table"}
          class="p-0 absolute flex items-center justify-center mt-4 w-full hidden"
          colspan="4"
          data-show={
            JS.show(
              transition: {"ease-in duration-300", "opacity-0", "opacity-100"},
              display: "flex",
              time: 300
            )
          }
          data-hide={
            JS.hide(
              transition: {"ease-out duration-300", "opacity-100", "opacity-0"},
              time: 300
            )
          }
        >
          <div class="flex items-center justify-center bg-gray-50 border p-3 pb-1 rounded-lg drop-shadow-md">
            <Loading.dots class="h-6 w-6" />
          </div>
        </.td>
      </.tr>
    </tbody>
    """
  end

  attr :id, :any, required: true, doc: "The parent component unique id."

  def bottom_loading(assigns) do
    ~H"""
    <tbody class="border-none absolute inset-x-0 bottom-0">
      <.tr>
        <.td
          id={"#{@id}-bottom-loading-table"}
          class="p-0 absolute flex items-center justify-center mb-4 w-full bottom-0 hidden"
          colspan="4"
          data-show={
            JS.show(
              transition: {"ease-in duration-500", "opacity-0", "opacity-100"},
              display: "flex",
              time: 500
            )
          }
          data-hide={
            JS.hide(
              transition: {"ease-out duration-500", "opacity-100", "opacity-0"},
              time: 500
            )
          }
        >
          <div class="flex items-center justify-center bg-gray-50 border p-3 pb-1 rounded-lg drop-shadow-md">
            <Loading.dots class="h-6 w-6" />
          </div>
        </.td>
      </.tr>
    </tbody>
    """
  end
end
