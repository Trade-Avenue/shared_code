defmodule CoreWeb.Components.Form.GenderTextField.Field do
  @moduledoc false

  use CoreWeb, :html

  attr :id, :any, required: true, doc: "The component unique id."
  attr :disabled, :boolean, required: true
  attr :field, :string, required: true
  attr :label, :string, required: true

  attr :target, :any
  attr :change, :string

  def render(assigns) do
    ~H"""
    <.field
      class="aria-readonly:bg-gray-100 dark:aria-readonly:bg-gray-700 aria-readonly:cursor-not-allowed"
      required
      id={@id}
      readonly={@disabled}
      aria-readonly={"#{@disabled}"}
      field={@field}
      type="textarea"
      placeholder="Text"
      phx-debounce="500ms"
      label={@label}
      phx-target={@target}
      phx-change={@change}
      phx-hook="TextToCursorHook"
    />
    """
  end
end
