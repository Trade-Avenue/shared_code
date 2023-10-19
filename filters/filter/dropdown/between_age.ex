defmodule CoreWeb.Components.Filter.Dropdown.BetweenAge do
  @moduledoc false

  alias CoreWeb.Components.Filter.Helpers.FilterInfo
  alias CoreWeb.Components.Helpers.Target

  alias AshQueryBuilder.Filter

  use CoreWeb, :live_component

  attr :id, :any, required: true, doc: "The component unique id."

  attr :target, Target, default: nil

  attr :filter_info, FilterInfo, required: true, doc: "The info to use for creating filters."

  attr :builder, AshQueryBuilder, required: true, doc: "The query builder."

  attr :debounce, :integer, default: 500, doc: "Delay the event by the specified milliseconds."

  attr :min_placeholder, :string, default: nil, doc: "The minimum input placeholder text."
  attr :max_placeholder, :string, default: nil, doc: "The maximum input placeholder text."

  def live_render(assigns), do: ~H"<.live_component module={__MODULE__} {assigns} />"

  def update(assigns, socket) do
    %{filter_info: %{id: key}, builder: builder} = assigns

    [min, max] = find_or_create_values(builder, key)

    assigns = Map.drop(assigns, [:target, :builder])

    socket =
      socket
      |> assign(assigns)
      |> maybe_assign_form(to_form(%{"min" => min, "max" => max}))

    {:ok, socket}
  end

  def handle_event("update_input", params, socket) do
    %{filter_info: filter_info, target: target} = socket.assigns

    %{"max" => max, "min" => min} = params

    min = to_integer(min)
    max = to_integer(max)

    if not is_nil(min) and not is_nil(max) and min > max do
      form =
        to_form(%{"min" => min, "max" => max}, errors: [nil: "min can't be bigger than max"])

      {:noreply, maybe_assign_form(socket, form)}
    else
      # We invert max and min since we are converting it to dates
      min_date = to_min_date(max)
      max_date = to_max_date(min)

      filter = create_filter(filter_info, min_date, max_date, min, max)

      Target.send_message(%{operation: :update_filters, filters: [filter]}, target)

      form = to_form(%{"min" => min, "max" => max})

      {:noreply, maybe_assign_form(socket, form)}
    end
  end

  defp to_integer(""), do: nil
  defp to_integer(value), do: String.to_integer(value)

  defp to_min_date(nil), do: nil
  defp to_min_date(age), do: Date.utc_today() |> Timex.shift(years: -(age + 1), days: 1)

  defp to_max_date(nil), do: nil
  defp to_max_date(age), do: Date.utc_today() |> Timex.shift(years: -age)

  defp maybe_assign_form(%{assigns: %{form: form}} = socket, form), do: socket
  defp maybe_assign_form(socket, form), do: assign(socket, form: form)

  defp find_or_create_values(builder, id) do
    case AshQueryBuilder.find_filter(builder, id, only_enabled?: true) do
      nil -> [nil, nil]
      %{metadata: %{min: min, max: max}} -> [min, max]
    end
  end

  defp create_filter(%{id: id, field: field, path: path}, nil, nil, _, _),
    do: Filter.new(id, path, field, :between, [], enabled?: false)

  defp create_filter(%{id: id, field: field, path: path}, min_date, max_date, min, max) do
    Filter.new(id, path, field, :between, [min_date, max_date],
      enabled?: true,
      metadata: %{min: min, max: max}
    )
  end
end
