defmodule CoreWeb.Components.Filter.Select do
  @moduledoc false

  alias CoreWeb.Components.Form.Select

  alias CoreWeb.Components.Filter.Helpers.FilterInfo
  alias CoreWeb.Components.Helpers.Target

  alias AshQueryBuilder.Filter

  use CoreWeb, :live_component

  attr :id, :any, required: true, doc: "The component unique id."

  attr :target, Target, default: nil

  attr :filter_info, FilterInfo, required: true, doc: "The filter info."

  attr :builder, AshQueryBuilder, required: true, doc: "The query builder."

  attr :options, :list, required: true, doc: "The options list."

  attr :searchable?, :boolean, default: true
  attr :search_placeholder, :string, default: "Search"

  def live_render(assigns), do: ~H"<.live_component module={__MODULE__} {assigns} />"

  def update(%{operation: :updated_value, value: value}, socket) do
    %{filter_info: filter_info, target: target} = socket.assigns

    filter = create_filter(filter_info, value)

    Target.send_message(%{operation: :update_filters, filters: [filter]}, target)

    {:ok, socket}
  end

  def update(assigns, socket) do
    %{id: id, filter_info: %{id: key}, builder: builder} = assigns

    assigns = Map.drop(assigns, [:builder])

    value = find_value(builder, key)

    element_suffix = if is_nil(value), do: "empty-option", else: value

    socket =
      socket
      |> assign(assigns)
      |> maybe_update_value(value)
      |> push_event("js-exec", %{to: "##{id}-#{element_suffix}", attr: "phx-mounted"})

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <Select.live_render
        id={@id}
        default_option={@value}
        options={@options}
        target={Target.new(@id, __MODULE__)}
        data-option-changed={%JS{}}
        searchable?={@searchable?}
        search_placeholder={@search_placeholder}
      >
        <:trigger_element :let={[parent_id: parent_id, field: field, options: options, empty?: empty?]}>
          <Select.Button.render parent_id={parent_id} field={field} options={options} empty?={empty?} />
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
          Empty list
        </:empty_list_element>
      </Select.live_render>
    </div>
    """
  end

  defp maybe_update_value(%{assigns: %{value: value}} = socket, value), do: socket
  defp maybe_update_value(socket, value), do: assign(socket, value: value)

  defp create_filter(%{id: id, field: field, path: path}, nil),
    do: Filter.new(id, path, field, :==, nil, enabled?: false)

  defp create_filter(%{id: id, field: field, path: path}, value),
    do: Filter.new(id, path, field, :==, value, enabled?: true)

  defp find_value(builder, id) do
    with %{value: value} <- AshQueryBuilder.find_filter(builder, id, only_enabled?: true),
         do: value
  end
end
