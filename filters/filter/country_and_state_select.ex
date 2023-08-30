defmodule FeedbackCupcakeWeb.Components.Filter.CountryAndStateSelect do
  @moduledoc false

  alias FeedbackCupcakeWeb.Components.Form.CountryAndStateSelect

  alias FeedbackCupcakeWeb.Components.Filter.Helpers.FilterInfo
  alias FeedbackCupcakeWeb.Components.Helpers.Target

  alias FeedbackCupcake.Utils.CountriesAndStates

  alias AshQueryBuilder.Filter

  use FeedbackCupcakeWeb, :live_component

  attr :id, :any, required: true, doc: "The component unique id."

  attr :target, Target, default: nil

  attr :country_filter_info, FilterInfo, required: true, doc: "The country filter info."
  attr :state_filter_info, FilterInfo, required: true, doc: "The state filter info."

  attr :builder, AshQueryBuilder, required: true, doc: "The query builder."

  def live_render(assigns) do
    ~H"""
    <.live_component
      module={__MODULE__}
      id={@id}
      target={@target}
      country_filter_info={@country_filter_info}
      state_filter_info={@state_filter_info}
      builder={@builder}
    />
    """
  end

  def update(%{operation: :updated_state, value: value}, socket) do
    %{state_filter_info: filter_info, target: target, country: country} = socket.assigns

    filter = create_filter(filter_info, value, CountriesAndStates.state_name(country, value))

    Target.send_message(%{operation: :update_filters, filters: [filter]}, target)

    {:ok, socket}
  end

  def update(%{operation: :updated_country, value: value}, socket) do
    %{
      country_filter_info: country_filter_info,
      state_filter_info: state_filter_info,
      target: target
    } = socket.assigns

    filters = [
      create_filter(country_filter_info, value, CountriesAndStates.country_name(value)),
      create_filter(state_filter_info, nil, nil)
    ]

    Target.send_message(%{operation: :update_filters, filters: filters}, target)

    {:ok, socket}
  end

  def update(assigns, socket) do
    %{
      country_filter_info: %{id: country_key},
      state_filter_info: %{id: state_key},
      builder: builder
    } = assigns

    country = find_value(builder, country_key)
    state = find_value(builder, state_key)

    assigns = Map.take(assigns, [:id, :target, :country_filter_info, :state_filter_info])

    socket =
      socket
      |> assign(assigns)
      |> maybe_update_country(country)
      |> maybe_update_state(state)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <CountryAndStateSelect.live_render
        id={"#{@id}-select"}
        target={Target.new(@id, __MODULE__)}
        country={@country}
        state={@state}
      />
    </div>
    """
  end

  defp maybe_update_country(%{assigns: %{country: country}} = socket, country), do: socket
  defp maybe_update_country(socket, country), do: assign(socket, country: country)

  defp maybe_update_state(%{assigns: %{state: state}} = socket, state), do: socket
  defp maybe_update_state(socket, state), do: assign(socket, state: state)

  defp create_filter(%{id: id, field: field, path: path}, nil, _),
    do: Filter.new(id, path, field, :==, nil, enabled?: false)

  defp create_filter(%{id: id, field: field, path: path}, value, value_name) do
    Filter.new(id, path, field, :==, value, enabled?: true, metadata: %{value_name: value_name})
  end

  defp find_value(builder, id) do
    with %{value: value} <- AshQueryBuilder.find_filter(builder, id, only_enabled?: true),
         do: value
  end
end
