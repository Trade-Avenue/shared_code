defmodule CoreWeb.Components.Filter.Descriptions do
  @moduledoc false

  alias CoreWeb.Components.Filter.Descriptions
  alias CoreWeb.Components.{Tooltip, Helpers.Target}

  alias AshQueryBuilder.Filter

  use CoreWeb, :live_component

  attr :id, :any, required: true, doc: "The component unique id."

  attr :target, Target, default: nil

  attr :builder, AshQueryBuilder, required: true

  attr :fields_names, :map, default: %{}

  attr :show_clear_all, :boolean, default: true

  def live_render(assigns), do: ~H"<.live_component module={__MODULE__} {assigns} />"

  def update(%{builder: builder, show_clear_all: show_clear_all?} = assigns, socket) do
    assigns = Map.drop(assigns, [:builder, :show_clear_all])

    filters = Enum.filter(builder.filters, &keep?/1)

    show_clear_all? = show_clear_all? and not Enum.empty?(filters)

    socket =
      socket
      |> assign(assigns)
      |> assign(filters: filters)
      |> assign(show_clear_all?: show_clear_all?)

    {:ok, socket}
  end

  defp keep?(%AshQueryBuilder.FilterScope{filters: filters}),
    do: Enum.any?(filters, & &1.enabled?)

  defp keep?(%{enabled?: enabled?}), do: enabled?

  def handle_event("remove_filter", %{"id" => filter_id}, socket) do
    %{target: target} = socket.assigns

    Target.send_message(%{operation: :clear_filter, filter_id: filter_id}, target)

    {:noreply, socket}
  end

  def handle_event("clear_filters", _, socket) do
    %{target: target} = socket.assigns

    Target.send_message(%{operation: :clear_filters}, target)

    {:noreply, socket}
  end

  defp clear_filters(target, id) do
    id = "#{id}-clear-all"

    JS.set_attribute({"disabled", ""})
    |> JS.hide(to: "##{id}-icon", time: 0)
    |> JS.show(to: "##{id}-loading", time: 0)
    |> JS.push("clear_filters", target: target)
  end

  defp remove_filter(target, id) do
    JS.hide(time: 0)
    |> JS.show(to: "##{id}-loading", time: 0, display: "flex")
    |> JS.push("remove_filter", target: target)
  end

  defp description(%{filter: %AshQueryBuilder.FilterScope{}} = assigns) do
    %{filter: %{filters: filters}} = assigns

    # We only support scopes with the same filters for now, so we check it here and crash otherwise
    1 = filters |> Enum.uniq_by(& &1.__struct__) |> Enum.count()

    ~H"""
    <Descriptions.Scope.field_names filter={@filter} names_map={@names_map} />
    <.value_part filter={List.first(@filter.filters)} />
    """
  end

  defp description(%{filter: filter, names_map: names_map} = assigns) do
    field_name = Descriptions.Helper.maybe_get_name_from_map(filter.field, filter.path, names_map)

    assigns = assign(assigns, %{field_name: field_name})

    ~H"""
    <span class="font-bold"><%= @field_name %></span>
    <.value_part filter={@filter} />
    """
  end

  defp value_part(%{filter: %Filter.In{}} = assigns), do: Descriptions.In.value_part(assigns)

  defp value_part(%{filter: %Filter.IsNil{}} = assigns),
    do: Descriptions.IsNil.value_part(assigns)

  defp value_part(%{filter: %Filter.Equal{}} = assigns),
    do: Descriptions.Equal.value_part(assigns)

  defp value_part(%{filter: %Filter.NotEqual{}} = assigns),
    do: Descriptions.NotEqual.value_part(assigns)

  defp value_part(%{filter: %Filter.LessThan{}} = assigns),
    do: Descriptions.LessThan.value_part(assigns)

  defp value_part(%{filter: %Filter.LessThanOrEqual{}} = assigns),
    do: Descriptions.LessThanOrEqual.value_part(assigns)

  defp value_part(%{filter: %Filter.GreaterThan{}} = assigns),
    do: Descriptions.GreaterThan.value_part(assigns)

  defp value_part(%{filter: %Filter.GreaterThanOrEqual{}} = assigns),
    do: Descriptions.GreaterThanOrEqual.value_part(assigns)

  defp value_part(%{filter: %Filter.Between{}} = assigns),
    do: Descriptions.Between.value_part(assigns)

  defp value_part(%{filter: %Filter.Similarity{}} = assigns),
    do: Descriptions.Similarity.value_part(assigns)

  defp value_part(%{filter: %Filter.LeftWordSimilarity{}} = assigns),
    do: Descriptions.Similarity.value_part(assigns)

  defp value_part(%{filter: %Filter.RightWordSimilarity{}} = assigns),
    do: Descriptions.Similarity.value_part(assigns)

  defp value_part(%{filter: %Filter.LeftStrictWordSimilarity{}} = assigns),
    do: Descriptions.Similarity.value_part(assigns)

  defp value_part(%{filter: %Filter.RightStrictWordSimilarity{}} = assigns),
    do: Descriptions.Similarity.value_part(assigns)
end
