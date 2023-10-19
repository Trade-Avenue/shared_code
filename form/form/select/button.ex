defmodule CoreWeb.Components.Form.Select.Button do
  @moduledoc false

  alias Phoenix.HTML.FormField

  use CoreWeb, :html

  attr :parent_id, :any, required: true

  attr :field, FormField, required: true
  attr :options, :list, required: true, doc: "The options list."

  attr :empty?, :boolean, default: false, doc: "Is the options list empty?."

  attr :class, :string, default: ""

  attr :image_module, :atom, default: nil

  def render(%{empty?: true} = assigns) do
    ~H"""
    <div class={["pc-dropdown__trigger-button--with-label", @class]}>
      <div class="flex items-center justify-center">
        Empty
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class={["pc-dropdown__trigger-button--with-label", @class]}>
      <div class="flex items-center justify-center">
        <img
          :if={@image_module}
          id={"#{@parent_id}-trigger-image"}
          src={@image_module.path(@field.value)}
          class="inline mr-2 h-3 rounded-sm"
          phx-update="ignore"
        />
        <span id={"#{@parent_id}-trigger-text"} phx-update="ignore">
          <%= name(@field.value, @options) %>
        </span>
        <Heroicons.chevron_down solid class="w-3 h-3 ml-2.5 stroke-current stroke-2" />
      </div>
    </div>
    """
  end

  defp name(nil, _), do: nil
  defp name(value, options), do: List.keyfind!(options, value, 1) |> elem(0)
end
