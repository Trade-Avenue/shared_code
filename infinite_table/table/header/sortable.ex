defmodule FeedbackCupcakeWeb.Components.Table.Header.Sortable do
  @moduledoc false

  alias FeedbackCupcakeWeb.Components.Tooltip

  alias FeedbackCupcakeWeb.Components.Helpers.Target

  alias AshQueryBuilder.Sorter

  use FeedbackCupcakeWeb, :live_component

  import PhxComponentHelpers

  attr :id, :any, required: true, doc: "The component unique id."

  attr :target, Target, default: nil

  attr :query_builder, AshQueryBuilder, required: true, doc: "The query builder."

  attr :key, :string, required: true
  attr :field, :atom, required: true

  attr :class, :string, default: ""

  slot :inner_block

  def live_render(assigns) do
    ~H"""
    <.live_component
      module={__MODULE__}
      id={@id}
      target={@target}
      query_builder={@query_builder}
      key={@key}
      field={@field}
      class={@class}
      inner_block={@inner_block}
    />
    """
  end

  def update(%{query_builder: builder, key: key} = assigns, socket) do
    order = find_order(builder, key)

    assigns =
      assigns
      |> Map.take([:id, :target, :key, :field, :class, :inner_block])
      |> extend_class("pc-table__th text-slate-600")

    socket = socket |> assign(assigns) |> assign(order: order)

    {:ok, socket}
  end

  def handle_event("update_sort", _, socket) do
    %{id: id, key: key, field: field, order: order, target: target} = socket.assigns

    order = update_order(order)

    sorter = create_sorter(key, field, order)

    Target.send_message(%{operation: :update_sorter, sorter: sorter}, target)

    socket =
      socket
      |> assign(order: order)
      |> push_event("js-exec", %{to: "##{id}-button", attr: "data-after-clear"})

    {:noreply, socket}
  end

  defp find_order(builder, id) do
    with %{order: order} <- AshQueryBuilder.find_sorter(builder, id) do
      order
    end
  end

  defp start_loading(id, target) do
    JS.set_attribute({"disabled", ""})
    |> JS.add_class("hidden", to: "##{id}-sort-icon", time: 0)
    |> JS.remove_class("hidden", to: "##{id}-loading", time: 0)
    |> JS.push("update_sort", target: target)
  end

  defp end_loading(id) do
    JS.remove_attribute("disabled")
    |> JS.add_class("hidden", to: "##{id}-loading", time: 0)
    |> JS.remove_class("hidden", to: "##{id}-sort-icon", time: 0)
  end

  defp change_sort_icons_on_leave(js \\ %JS{}, id) do
    js
    |> JS.add_class("hidden", to: "##{id}-next", time: 0)
    |> JS.remove_class("hidden", to: "##{id}-current", time: 0)
  end

  defp change_sort_icons_on_enter(id) do
    JS.add_class("hidden", to: "##{id}-current", time: 0)
    |> JS.remove_class("hidden", to: "##{id}-next", time: 0)
  end

  defp update_order(nil), do: :asc
  defp update_order(:asc), do: :desc
  defp update_order(:desc), do: :asc

  defp tooltip_message(nil), do: tooltip_message(:desc)
  defp tooltip_message(:desc), do: "Sort column in ascending order"
  defp tooltip_message(:asc), do: "Sort column in descending order"

  defp create_sorter(id, field, order), do: Sorter.new(id, field, order)
end
