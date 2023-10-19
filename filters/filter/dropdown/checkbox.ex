defmodule CoreWeb.Components.Filter.Dropdown.Checkbox do
  @moduledoc false

  alias CoreWeb.Components.Filter.Helpers.FilterInfo
  alias CoreWeb.Components.Form.CheckboxGroup
  alias CoreWeb.Components.Helpers.Target

  alias AshQueryBuilder.Filter

  use CoreWeb, :live_component

  attr :id, :any, required: true, doc: "The component unique id."

  attr :target, Target, default: nil

  attr :options, :list, doc: "The checkbox options."

  attr :filter_info, FilterInfo, required: true, doc: "The info to use for creating filters."

  attr :builder, AshQueryBuilder, required: true, doc: "The query builder."

  slot :title, doc: "The title slot."

  def live_render(assigns), do: ~H"<.live_component module={__MODULE__} {assigns} />"

  def update(assigns, socket) do
    %{filter_info: %{id: key}, options: options, builder: builder} = assigns

    values = find_or_create_values(builder, key)

    assigns = Map.drop(assigns, [:builder])

    all_selected? = all_selected?(values, options)

    socket =
      socket
      |> assign(assigns)
      |> assign(all_selected?: all_selected?)
      |> maybe_assign_form(to_form(%{key => values}))

    {:ok, socket}
  end

  def handle_event("update_checkbox", params, socket) do
    %{filter_info: filter_info, target: target, options: options} = socket.assigns

    values = params |> Map.get(filter_info.id, []) |> List.flatten()

    all_selected? = all_selected?(values, options)

    filter = filter_info |> create_filter(values)

    Target.send_message(%{operation: :update_filters, filters: [filter]}, target)

    form = to_form(%{filter_info.id => values})

    {:noreply, socket |> maybe_assign_form(form) |> assign(all_selected?: all_selected?)}
  end

  def handle_event("toggle_select_all", _, %{assigns: %{all_selected?: true}} = socket) do
    %{filter_info: %{id: key}} = socket.assigns

    handle_event("update_checkbox", %{key => []}, socket)
  end

  def handle_event("toggle_select_all", _, socket) do
    %{options: options, filter_info: %{id: key}} = socket.assigns

    values = Enum.map(options, fn {_, value} -> value end)

    handle_event("update_checkbox", %{key => values}, socket)
  end

  defp all_selected?(values, options),
    do: Enum.all?(options, fn {_, value} -> value in values end)

  defp maybe_assign_form(%{assigns: %{form: form}} = socket, form), do: socket
  defp maybe_assign_form(socket, form), do: assign(socket, form: form)

  defp find_or_create_values(builder, id) do
    case AshQueryBuilder.find_filter(builder, id, only_enabled?: true) do
      nil -> []
      %{value: values} -> values
    end
  end

  defp create_filter(%{id: id, field: field, path: path}, []),
    do: Filter.new(id, path, field, :in, [], enabled?: false)

  defp create_filter(%{id: id, field: field, path: path}, values),
    do: Filter.new(id, path, field, :in, values, enabled?: true)
end
