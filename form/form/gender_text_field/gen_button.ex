defmodule CoreWeb.Components.Form.GenderTextField.GenButton do
  @moduledoc false

  use CoreWeb, :html

  attr :auto_gen?, :boolean, required: true
  attr :target, Phoenix.LiveComponent.CID, required: true

  def render(assigns) do
    ~H"""
    <.button
      with_icon
      type="button"
      color="gray"
      variant="outline"
      phx-click="toggle_auto_gen"
      phx-target={@target}
    >
      <div :if={@auto_gen?} class="flex justify-center gap-2">
        <Heroicons.pause_circle solid class="dark:text-red-300 text-red-500 h-5 w-5" />
        Stop Generating
      </div>
      <div :if={not @auto_gen?} class="flex justify-center gap-2">
        <Heroicons.play_circle solid class="dark:text-green-300 text-green-500 h-5 w-5" />
        Generate Text
      </div>
    </.button>
    """
  end
end
