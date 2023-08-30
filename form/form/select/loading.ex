defmodule FeedbackCupcakeWeb.Components.Form.Select.Loading do
  @moduledoc false

  use FeedbackCupcakeWeb, :html

  attr :id, :any, required: true

  attr :class, :string, default: ""

  attr :button_class, :string, default: ""

  def render(assigns) do
    ~H"""
    <div id={@id} class={["pc-dropdown", @class]}>
      <div class={["pc-dropdown__trigger-button--with-label", @button_class]}>
        <.spinner class="h-5 w-5 mr-2" /> Loading
      </div>
    </div>
    """
  end
end
