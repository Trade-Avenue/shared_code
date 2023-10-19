defmodule CoreWeb.Components.Filter.Dropdown.ClearFilters do
  @moduledoc false

  alias CoreWeb.Components.Helpers.Target

  use CoreWeb, :live_component

  attr :id, :any, required: true, doc: "The component unique id."

  attr :target, Target, default: nil

  attr :builder, AshQueryBuilder, required: true

  def live_render(assigns), do: ~H"<.live_component module={__MODULE__} {assigns} />"

  def update(%{id: id, target: target, builder: builder}, socket) do
    disabled? = empty?(builder.filters)

    {:ok, assign(socket, id: id, target: target, disabled?: disabled?)}
  end

  def handle_event("clear_filters", _, socket) do
    %{id: id, target: target} = socket.assigns

    Target.send_message(%{operation: :clear_filters}, target)

    {:noreply, push_event(socket, "js-exec", %{to: "##{id}", attr: "data-after-clear"})}
  end

  defp start_loading(id, target) do
    JS.set_attribute({"disabled", ""})
    |> JS.hide(to: "##{id}-icon", time: 0)
    |> JS.show(to: "##{id}-loading", time: 0)
    |> JS.push("clear_filters", target: target)
  end

  defp end_loading(id) do
    JS.remove_attribute("disabled")
    |> JS.hide(to: "##{id}-loading", time: 0)
    |> JS.show(to: "##{id}-icon", time: 0)
  end

  defp empty?(filters), do: filters |> Enum.filter(&keep?/1) |> Enum.empty?()

  defp keep?(%AshQueryBuilder.FilterScope{filters: filters}),
    do: Enum.any?(filters, & &1.enabled?)

  defp keep?(%{enabled?: enabled?}), do: enabled?
end
