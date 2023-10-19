defmodule CoreWeb.Components.Form.CountryAndStateSelect.InnerComponents do
  @moduledoc false

  alias CoreWeb.Components.Form.CountryAndStateSelect.CountryImages

  alias CoreWeb.Components.{Form.Select, Helpers.Target}

  use CoreWeb, :html

  attr :id, :any, required: true, doc: "The parent component unique id."

  attr :countries, :list, required: true, doc: "The list of countries options."
  attr :country, :string, required: true, doc: "The default country."

  attr :target, Target, default: nil

  def country_select(assigns) do
    ~H"""
    <Select.Loading.render id={"#{@id}-country-loading"} button_class="rounded-r-none bg-gray-50" />

    <Select.live_render
      id={"#{@id}-country"}
      default_option={@country}
      options={@countries}
      target={@target}
      data-option-changed={start_loading_js("#{@id}-state")}
      data-start-loading={start_loading_js("#{@id}-country")}
      data-end-loading={end_loading_js("#{@id}-country")}
      search_placeholder="Search for country"
      class="hidden"
    >
      <:trigger_element :let={[parent_id: parent_id, field: field, options: options, empty?: empty?]}>
        <Select.Button.render
          parent_id={parent_id}
          field={field}
          options={options}
          empty?={empty?}
          class="rounded-r-none bg-gray-50"
          image_module={CountryImages}
        />
      </:trigger_element>

      <:option_element :let={[
        parent_id: parent_id,
        name: name,
        value: value,
        field: field,
        target: target
      ]}>
        <Select.Option.render
          parent_id={parent_id}
          name={name}
          value={value}
          field={field}
          target={target}
          image_module={CountryImages}
        />
      </:option_element>
    </Select.live_render>
    """
  end

  attr :id, :any, required: true, doc: "The parent component unique id."

  attr :states, :list, required: true, doc: "The list of states options."
  attr :state, :string, required: true, doc: "The default state."

  attr :target, Target, default: nil

  def state_select(assigns) do
    ~H"""
    <Select.Loading.render id={"#{@id}-state-loading"} button_class="rounded-l-none border-l-0" />

    <Select.live_render
      id={"#{@id}-state"}
      default_option={@state}
      options={@states}
      target={@target}
      data-option-changed={%JS{}}
      data-start-loading={start_loading_js("#{@id}-state")}
      data-end-loading={end_loading_js("#{@id}-state")}
      class="hidden"
    >
      <:trigger_element :let={[parent_id: parent_id, field: field, options: options, empty?: empty?]}>
        <Select.Button.render
          parent_id={parent_id}
          field={field}
          options={options}
          empty?={empty?}
          class="rounded-l-none border-l-0"
        />
      </:trigger_element>

      <:option_element :let={[
        parent_id: parent_id,
        name: name,
        value: value,
        field: field,
        target: target
      ]}>
        <Select.Option.render
          parent_id={parent_id}
          name={name}
          value={value}
          field={field}
          target={target}
        />
      </:option_element>

      <:empty_list_element>
        This country doesn't have any state
      </:empty_list_element>
    </Select.live_render>
    """
  end

  defp start_loading_js(id),
    do: JS.remove_class("hidden", to: "##{id}-loading") |> JS.add_class("hidden", to: "##{id}")

  defp end_loading_js(id),
    do: JS.add_class("hidden", to: "##{id}-loading") |> JS.remove_class("hidden", to: "##{id}")
end
