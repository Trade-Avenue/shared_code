defmodule CoreWeb.Components.Form.CheckboxGroup do
  @moduledoc false

  use CoreWeb, :html

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :class, :string, default: nil, doc: "the class to add to the input"

  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :disabled_options, :list, default: [], doc: "the options to disable in a checkbox group"

  attr :group_layout, :string,
    values: ["row", "col"],
    default: "row",
    doc: "the layout of the inputs in a group"

  attr :empty_message, :string,
    default: nil,
    doc: "the message to display when there are no options available."

  attr :rest, :global

  def render(%{field: field} = assigns) do
    assigns =
      assigns
      |> assign_new(:name, fn -> field.name <> "[]" end)
      |> assign_new(:value, fn -> field.value end)
      |> assign_new(:checked, fn ->
        values =
          case field.value do
            value when is_binary(value) -> [value]
            value when is_list(value) -> value
            _ -> []
          end

        Enum.map(values, &to_string/1)
      end)

    ~H"""
    <input type="hidden" name={@name} value="" />
    <div class={[
      "pc-checkbox-group",
      @group_layout == "row" && "pc-checkbox-group--row",
      @group_layout == "col" && "pc-checkbox-group--col",
      @class
    ]}>
      <%= for {label, value} <- @options do %>
        <label class="pc-checkbox-label">
          <input
            type="checkbox"
            name={@name <> "[]"}
            checked_value={value}
            unchecked_value=""
            value={value}
            checked={to_string(value) in @checked}
            hidden_input={false}
            class="pc-checkbox"
            disabled={value in @disabled_options}
            {@rest}
          />
          <div>
            <%= label %>
          </div>
        </label>
      <% end %>

      <%= if @empty_message && Enum.empty?(@options) do %>
        <div class="pc-checkbox-group--empty-message">
          <%= @empty_message %>
        </div>
      <% end %>
    </div>
    """
  end
end
