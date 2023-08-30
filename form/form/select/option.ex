defmodule FeedbackCupcakeWeb.Components.Form.Select.Option do
  @moduledoc false

  alias Phoenix.{HTML.FormField, LiveComponent.CID}

  use FeedbackCupcakeWeb, :html

  attr :parent_id, :any, required: true

  attr :name, :string, required: true
  attr :value, :string, required: true

  attr :field, FormField, required: true

  attr :target, CID, required: true

  attr :image_module, :atom, default: nil

  def render(%{value: value, field: field} = assigns) do
    assigns = assign(assigns, checked?: checked?(value, field))

    ~H"""
    <li>
      <input
        type="radio"
        id={id(@value, @parent_id)}
        name="value"
        value={@value || "empty_option"}
        class="peer"
        phx-change={update_and_send_value_js(@name, @value, @target, @parent_id, @image_module)}
        phx-mounted={@checked? && update_value_js(@name, @value, @parent_id, @image_module)}
        style="display: none;"
        checked={@checked?}
      />
      <label
        for={id(@value, @parent_id)}
        class="pc-dropdown__menu-item rounded-sm peer-checked:bg-gray-100 peer-checked:text-blue-600"
      >
        <div class="block">
          <img
            :if={@image_module}
            src={@image_module.path(@value)}
            class="inline mr-2 h-3 rounded-sm"
          /> <%= @name %>
        </div>
      </label>
    </li>
    """
  end

  defp id(nil, parent_id), do: "#{parent_id}-empty-option"
  defp id(value, parent_id), do: "#{parent_id}-#{value}"

  defp checked?(value, %{value: value}), do: true
  defp checked?(_, _), do: false

  defp update_value_js(name, _, parent_id, nil),
    do: do_update_value_js(name, parent_id)

  defp update_value_js(name, value, parent_id, image_module) do
    do_update_image_js(value, parent_id, image_module) |> do_update_value_js(name, parent_id)
  end

  defp update_and_send_value_js(name, _, target, parent_id, nil),
    do: do_update_value_js(name, parent_id) |> do_send_value_js(target)

  defp update_and_send_value_js(name, value, target, parent_id, image_module) do
    do_update_image_js(value, parent_id, image_module)
    |> do_update_value_js(name, parent_id)
    |> do_send_value_js(target)
  end

  defp do_update_image_js(js \\ %JS{}, value, parent_id, image_module)

  defp do_update_image_js(js, nil, parent_id, _),
    do: JS.add_class(js, "hidden", to: "##{parent_id}-trigger-image")

  defp do_update_image_js(js, value, parent_id, image_module) do
    js
    |> JS.set_attribute({"src", image_module.path(value)}, to: "##{parent_id}-trigger-image")
    |> JS.remove_class("hidden", to: "##{parent_id}-trigger-image")
  end

  defp do_update_value_js(js \\ %JS{}, name, parent_id) do
    js
    |> JSExtra.set_text_content(name, to: "##{parent_id}-trigger-text")
    |> JS.exec("phx-click-away", to: "##{parent_id}-dropdown")
    |> JS.exec("data-option-changed", to: "##{parent_id}")
  end

  defp do_send_value_js(js, target), do: JS.push(js, "update", target: target)
end
