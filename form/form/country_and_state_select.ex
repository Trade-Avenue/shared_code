defmodule CoreWeb.Components.Form.CountryAndStateSelect do
  @moduledoc false

  alias CoreWeb.Components.Form.CountryAndStateSelect.{DataLoad, InnerComponents}

  alias CoreWeb.Components.Helpers.Target

  use CoreWeb, :live_component

  attr :id, :any, required: true, doc: "The component unique id."

  attr :target, Target, default: nil

  attr :country, :string, default: nil, doc: "The selected country."
  attr :state, :string, default: nil, doc: "The selected country state."

  def live_render(assigns), do: ~H"<.live_component module={__MODULE__} {assigns} />"

  def update(%{operation: :updated_value} = assigns, socket) do
    # Triggered when the select component checked value changes

    %{id: id, target: target} = socket.assigns
    %{from: from_id, value: value} = assigns

    if from_id == "#{id}-country" do
      Target.send_message(%{operation: :updated_country, value: value}, target)

      socket = start_async(socket, :states_load, fn -> DataLoad.load_states(value) end)

      {:ok, assign(socket, country: value, state: nil, states: [])}
    else
      Target.send_message(%{operation: :updated_state, value: value}, target)

      {:ok, assign(socket, state: value)}
    end
  end

  def update(
        %{country: country, state: state},
        %{assigns: %{country: country, state: state}} = socket
      ) do
    # Triggered when the state and country are equal

    {:ok, socket}
  end

  def update(%{country: country} = assigns, %{assigns: %{country: country}} = socket) do
    # Triggered when the state is different but the country is not

    %{id: id} = socket.assigns
    %{state: state} = assigns

    element_suffix = if is_nil(state), do: "empty-option", else: state

    socket =
      socket
      |> push_event("js-exec", %{to: "##{id}-state-#{element_suffix}", attr: "phx-mounted"})
      |> assign(state: state)

    {:ok, socket}
  end

  def update(assigns, socket) do
    # Triggered when both the state and country are different or during initial load

    socket =
      if connected?(socket) do
        %{country: country, state: state} = assigns

        start_async(socket, :initial_load, fn -> DataLoad.initial_load(country, state) end)
      else
        socket
      end

    assigns = Map.drop(assigns, [:country, :state])

    socket =
      socket
      |> assign(assigns)
      |> assign(countries: [], country: nil, states: [], state: nil)
      |> push_data_load_event(:state, :started)
      |> push_data_load_event(:country, :started)

    {:ok, socket}
  end

  def handle_async(:initial_load, {:ok, %{country: country, state: state} = data}, socket) do
    %{target: target} = socket.assigns

    Target.send_message(%{operation: :updated_country_and_state, value: {country, state}}, target)

    socket =
      socket
      |> assign(data)
      |> push_data_load_event(:country, :finished)
      |> push_data_load_event(:state, :finished)

    {:noreply, socket}
  end

  def handle_async(:states_load, {:ok, %{state: state} = data}, socket) do
    %{target: target} = socket.assigns

    Target.send_message(%{operation: :updated_state, value: state}, target)

    socket = socket |> assign(data) |> push_data_load_event(:state, :finished)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div id={@id} class="flex">
      <InnerComponents.country_select
        id={@id}
        countries={@countries}
        country={@country}
        target={Target.new(@id, __MODULE__)}
      />

      <InnerComponents.state_select
        id={@id}
        states={@states}
        state={@state}
        target={Target.new(@id, __MODULE__)}
      />
    </div>
    """
  end

  defp push_data_load_event(%{assigns: %{id: id}} = socket, :state, :started),
    do: push_event(socket, "js-exec", %{to: "##{id}-state", attr: "data-start-loading"})

  defp push_data_load_event(%{assigns: %{id: id}} = socket, :state, :finished),
    do: push_event(socket, "js-exec", %{to: "##{id}-state", attr: "data-end-loading"})

  defp push_data_load_event(%{assigns: %{id: id}} = socket, :country, :started),
    do: push_event(socket, "js-exec", %{to: "##{id}-country", attr: "data-start-loading"})

  defp push_data_load_event(%{assigns: %{id: id}} = socket, :country, :finished),
    do: push_event(socket, "js-exec", %{to: "##{id}-country", attr: "data-end-loading"})
end
