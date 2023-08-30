defmodule FeedbackCupcakeWeb.Components.Form.CountryAndStateSelect do
  @moduledoc false

  alias FeedbackCupcakeWeb.Components.Form.CountryAndStateSelect.{DataLoad, InnerComponents}

  alias FeedbackCupcakeWeb.Components.Helpers.Target

  use FeedbackCupcakeWeb, :live_component

  attr :id, :any, required: true, doc: "The component unique id."

  attr :target, Target, default: nil

  attr :country, :string, default: nil, doc: "The selected country."
  attr :state, :string, default: nil, doc: "The selected country state."

  def live_render(assigns) do
    ~H"""
    <.live_component module={__MODULE__} id={@id} target={@target} country={@country} state={@state} />
    """
  end

  def update(%{operation: :initial_load} = assigns, socket) do
    # Triggered when the initial load data is fetched

    %{current_task: current_task} = socket.assigns

    if current_task == assigns.task do
      socket = socket |> handle_updated_country(assigns) |> handle_updated_state(assigns)

      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  def update(%{operation: :states_load} = assigns, socket) do
    # Triggered when the new states data is fetched

    %{current_task: current_task} = socket.assigns

    if current_task == assigns.task do
      {:ok, handle_updated_state(socket, assigns)}
    else
      {:ok, socket}
    end
  end

  def update(%{operation: :updated_value} = assigns, socket) do
    # Triggered when the select component checked value changes

    %{id: id, target: target} = socket.assigns
    %{from: from_id, value: value} = assigns

    if from_id == "#{id}-country" do
      Target.send_message(%{operation: :updated_country, value: value}, target)

      task = DataLoad.async_load_states(id, __MODULE__, value)

      {:ok, assign(socket, country: value, state: nil, states: [], current_task: task.pid)}
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
        %{id: id, country: country, state: state} = assigns

        task = DataLoad.async_initial_load(id, __MODULE__, country, state)

        assign(socket, current_task: task.pid)
      else
        assign(socket, current_task: nil)
      end

    assigns = Map.take(assigns, [:id, :target])

    socket =
      socket
      |> assign(assigns)
      |> assign(countries: [], country: nil, states: [], state: nil)
      |> push_data_load_event(:state, :started)
      |> push_data_load_event(:country, :started)

    {:ok, socket}
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

  defp handle_updated_country(socket, %{country: country} = assigns) do
    %{target: target} = socket.assigns

    Target.send_message(%{operation: :updated_country, value: country}, target)

    assigns = Map.take(assigns, [:countries, :country])

    socket
    |> assign(assigns)
    |> push_data_load_event(:country, :finished)
  end

  defp handle_updated_state(socket, %{state: state} = assigns) do
    %{target: target} = socket.assigns

    Target.send_message(%{operation: :updated_state, value: state}, target)

    assigns = Map.take(assigns, [:states, :state])

    socket
    |> assign(assigns)
    |> push_data_load_event(:state, :finished)
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
