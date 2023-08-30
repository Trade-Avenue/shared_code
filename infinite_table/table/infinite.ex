defmodule FeedbackCupcakeWeb.Components.Table.Infinite do
  @moduledoc false

  alias FeedbackCupcakeWeb.Components.Table.Infinite.InnerComponents

  use FeedbackCupcakeWeb, :live_component

  import PhxComponentHelpers

  attr :id, :any, required: true, doc: "The component unique id."

  attr :class, :string, default: ""

  attr :rest, :global

  attr :query, Ash.Query, required: true, doc: "The Ash query to get the data."
  attr :api, :atom, required: true, doc: "The API module to use with the query."

  attr :per_page_limit, :integer, default: 10, doc: "The number of rows per page request."

  attr :stored_rows, :integer,
    default: 30,
    doc: "The maximum number of rows we well keep before start discarding them."

  attr :stream_name, :atom, default: :rows, doc: "The stream name, defaults to `rows`."

  slot :headers, required: true
  slot :row, required: true

  def live_render(assigns) do
    ~H"""
    <.live_component
      module={__MODULE__}
      id={@id}
      class={@class}
      rest={@rest}
      query={@query}
      api={@api}
      per_page_limit={@per_page_limit}
      stored_rows={@stored_rows}
      stream_name={@stream_name}
      headers={@headers}
      row={@row}
    />
    """
  end

  def update(%{new_data: data}, socket), do: {:ok, handle_data(socket, data)}

  def update(%{query: query}, %{assigns: %{query: query}} = socket) do
    # Triggered when the query is the same, in this case we don't need to do anything

    {:ok, socket}
  end

  def update(assigns, socket) do
    # Triggered during mount for initial load

    %{id: id, stream_name: stream_name, query: query, api: api, per_page_limit: per_page_limit} =
      assigns

    if connected?(socket) do
      load_data_async(id, query, api, limit: per_page_limit)
    end

    assigns = extend_class(assigns, "relative")

    socket =
      socket
      |> assign(assigns)
      |> assign_page_checks(nil)
      |> stream(stream_name, [], reset: true)
      |> push_start_loading_event(id)

    {:ok, socket}
  end

  def handle_event("next-page", %{"cursor" => cursor}, socket) do
    %{id: id, query: query, api: api, has_next?: has_next?, per_page_limit: per_page_limit} =
      socket.assigns

    if has_next? do
      load_data_async(id, query, api, limit: per_page_limit, after: cursor)

      {:noreply, socket}
    else
      {:noreply, push_finished_loading_event(socket, id)}
    end
  end

  def handle_event("prev-page", %{"cursor" => cursor}, socket) do
    %{
      id: id,
      query: query,
      api: api,
      has_previous?: has_previous?,
      per_page_limit: per_page_limit
    } = socket.assigns

    if has_previous? do
      load_data_async(id, query, api, limit: per_page_limit, before: cursor)

      {:noreply, socket}
    else
      {:noreply, push_finished_loading_event(socket, id)}
    end
  end

  def handle_event("go_to_top", _params, socket) do
    %{id: id, query: query, api: api, per_page_limit: per_page_limit} = socket.assigns

    load_data_async(id, query, api, limit: per_page_limit)

    {:noreply, socket}
  end

  defp handle_data(socket, data) do
    %{id: id, stream_name: stream_name, stored_rows: stored_rows} = socket.assigns

    at = at(data)
    limit = limit(data, stored_rows)
    reset? = reset?(data)

    # If we are prepending the data, we need to first reverse it
    results = if at == 0, do: Enum.reverse(data.results), else: data.results

    socket
    |> assign_page_checks(data)
    |> stream(stream_name, results, at: at, limit: limit, reset: reset?)
    |> push_finished_loading_event(id)
  end

  defp limit(%{after: nil, before: nil}, stored_rows), do: -1 * stored_rows
  defp limit(%{after: _, before: nil}, stored_rows), do: -1 * stored_rows
  defp limit(%{after: nil, before: _}, stored_rows), do: stored_rows

  defp reset?(%{after: nil, before: nil}), do: true
  defp reset?(%{after: _, before: _}), do: false

  defp at(%{after: nil, before: nil}), do: -1
  defp at(%{after: _, before: nil}), do: -1
  defp at(%{after: nil, before: _}), do: 0

  defp assign_page_checks(socket, %{more?: more?, after: nil, before: nil}),
    do: assign(socket, %{has_next?: more?, has_previous?: false})

  defp assign_page_checks(socket, %{more?: more?, after: _, before: nil}),
    do: assign(socket, %{has_next?: more?, has_previous?: true})

  defp assign_page_checks(socket, %{more?: more?, after: nil, before: _}),
    do: assign(socket, %{has_next?: true, has_previous?: more?})

  defp assign_page_checks(socket, nil),
    do: assign(socket, %{has_next?: false, has_previous?: false})

  defp load_data_async(id, query, api, opts) do
    pid = self()

    Task.async(fn ->
      data = api.read!(query, page: opts)

      send_update(pid, __MODULE__, id: id, new_data: data)

      :ok
    end)
  end

  defp fetch_stream!(streams, stream_name), do: Map.fetch!(streams, stream_name)

  defp push_start_loading_event(socket, id),
    do: push_event(socket, "start_loading", %{id: id})

  defp push_finished_loading_event(socket, id),
    do: push_event(socket, "finished_loading", %{id: id})
end
