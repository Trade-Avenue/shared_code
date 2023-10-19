defmodule CoreWeb.Components.Form.GenderTextField.Switch do
  @moduledoc false

  use CoreWeb, :html

  attr :parent_id, :any, required: true, doc: "The component unique id."

  attr :target, Phoenix.LiveComponent.CID, required: true
  attr :click_on, :any, required: true
  attr :click_off, :any, required: true

  def render(assigns) do
    ~H"""
    <div class="px-2">
      <.icon_button
        id={"female-male-button-#{@parent_id}"}
        type="button"
        tooltip="Switch gender"
        color="gray"
        phx-target={@target}
        phx-click={@click_on.(@parent_id)}
      >
        <Heroicons.arrows_right_left />
      </.icon_button>

      <.icon_button
        id={"male-female-button-#{@parent_id}"}
        type="button"
        tooltip="Switch gender"
        color="gray"
        class="hidden"
        phx-target={@target}
        phx-click={@click_off.(@parent_id)}
      >
        <Heroicons.arrows_right_left />
      </.icon_button>
    </div>
    """
  end
end
