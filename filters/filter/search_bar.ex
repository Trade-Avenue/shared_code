defmodule CoreWeb.Components.Filter.SearchBar do
  @moduledoc false

  alias CoreWeb.Components.Filter.Helpers.FilterInfo
  alias CoreWeb.Components.Helpers.Target

  alias AshQueryBuilder.{Filter, FilterScope}

  use CoreWeb, :live_component

  import PhxComponentHelpers

  attr :id, :any, required: true, doc: "The component unique id."

  attr :placeholder, :string, default: nil, doc: "The search input placeholder text."

  attr :target, Target, default: nil

  attr :filter_info, FilterInfo, required: true, doc: "The info to use for creating filters."

  attr :builder, AshQueryBuilder, required: true, doc: "The query builder."

  attr :operation, :atom, default: :left_word_similarity, doc: "The filter operation."

  attr :debounce, :integer, default: 500, doc: "Delay the event by the specified milliseconds."

  attr :class, :string, default: "", doc: "The input class."
  attr :form_class, :string, default: "", doc: "The form class."

  def with_single_filter(assigns) do
    ~H"""
    <.live_component
      module={__MODULE__}
      id={@id}
      placeholder={@placeholder}
      target={@target}
      scope_id={nil}
      scope_operation={nil}
      filter_infos={[@filter_info]}
      builder={@builder}
      operation={@operation}
      debounce={@debounce}
      class={@class}
      form_class={@form_class}
    />
    """
  end

  attr :id, :any, required: true, doc: "The component unique id."

  attr :placeholder, :string, default: nil, doc: "The search input placeholder text."

  attr :target, Target, default: nil

  attr :scope_id, :string, required: true, doc: "The scope id."
  attr :scope_operation, :atom, default: :or, doc: "The scope operation."

  attr :filter_infos, :list, required: true, doc: "The info to use for creating filters."

  attr :builder, AshQueryBuilder, required: true, doc: "The query builder."

  attr :operation, :atom, default: :left_word_similarity, doc: "The filter operation."

  attr :debounce, :integer, default: 500, doc: "Delay the event by the specified milliseconds."

  attr :class, :string, default: "", doc: "The input class."
  attr :form_class, :string, default: "", doc: "The form class."

  def with_multiple_filters(assigns) do
    ~H"""
    <.live_component
      module={__MODULE__}
      id={@id}
      placeholder={@placeholder}
      target={@target}
      scope_id={@scope_id}
      scope_operation={@scope_operation}
      filter_infos={@filter_infos}
      builder={@builder}
      operation={@operation}
      debounce={@debounce}
      class={@class}
      form_class={@form_class}
    />
    """
  end

  def update(%{filter_infos: [%{id: key}]} = assigns, socket),
    do: do_update(key, assigns, socket)

  def update(%{scope_id: key} = assigns, socket),
    do: do_update(key, assigns, socket)

  def handle_event("update_input", params, %{assigns: %{scope_id: nil}} = socket) do
    %{filter_infos: [filter_info], target: target, operation: operation} = socket.assigns

    value = params |> Map.get(filter_info.id, nil) |> maybe_convert_to_nil()

    filter = create_filter(filter_info, value, operation)

    Target.send_message(%{operation: :update_filters, filters: [filter]}, target)

    form = to_form(%{filter_info.id => value})

    {:noreply, maybe_assign_form(socket, form)}
  end

  def handle_event("update_input", params, socket) do
    %{
      scope_id: scope_id,
      scope_operation: scope_operation,
      filter_infos: filter_infos,
      target: target,
      operation: operation
    } = socket.assigns

    value = params |> Map.get(scope_id, nil) |> maybe_convert_to_nil()

    scope = create_scope(scope_id, scope_operation, filter_infos, value, operation)

    Target.send_message(%{operation: :update_filters, filters: [scope]}, target)

    form = to_form(%{scope_id => value})

    {:noreply, maybe_assign_form(socket, form)}
  end

  defp do_update(key, assigns, socket) do
    %{builder: builder, class: class, form_class: form_class} = assigns

    value = find_value(builder, key)

    assigns =
      Map.take(assigns, [
        :id,
        :placeholder,
        :scope_id,
        :scope_operation,
        :filter_infos,
        :target,
        :operation,
        :debounce
      ])

    assigns =
      assigns
      |> extend_class("pl-10 pc-text-input #{class}")
      |> extend_class(form_class, attribute: :form_class)

    socket =
      socket
      |> assign(assigns)
      |> assign(key: key)
      |> maybe_assign_form(to_form(%{key => value}))

    {:ok, socket}
  end

  defp maybe_convert_to_nil(""), do: nil
  defp maybe_convert_to_nil(value), do: value

  defp maybe_assign_form(%{assigns: %{form: form}} = socket, form), do: socket
  defp maybe_assign_form(socket, form), do: assign(socket, form: form)

  defp find_value(builder, id) do
    case AshQueryBuilder.find_filter(builder, id, only_enabled?: true) do
      %{value: value} -> value
      %{filters: [%{value: value} | _]} -> value
      nil -> nil
    end
  end

  defp create_scope(scope_id, scope_operation, filter_infos, value, operation) do
    scope = FilterScope.new(scope_operation, id: scope_id)

    Enum.reduce(filter_infos, scope, fn filter_info, scope ->
      filter = create_filter(filter_info, value, operation)

      FilterScope.add_filter(scope, filter)
    end)
  end

  defp create_filter(%{id: id, field: field, path: path}, nil, operation),
    do: Filter.new(id, path, field, operation, nil, enabled?: false)

  defp create_filter(%{id: id, field: field, path: path}, value, operation),
    do: Filter.new(id, path, field, operation, value, enabled?: true)
end
