defmodule FeedbackCupcakeWeb.Components.Filter.Descriptions.Scope do
  @moduledoc false

  alias FeedbackCupcakeWeb.Components.Filter.Descriptions.Helper

  use FeedbackCupcakeWeb, :html

  def field_names(%{filter: scope, names_map: names_map} = assigns) do
    {last, rest} =
      scope.filters
      |> Enum.map(fn filter ->
        Helper.maybe_get_name_from_map(filter.field, filter.path, names_map)
      end)
      |> Enum.sort()
      |> List.pop_at(-1)

    assigns = assign(assigns, %{last: last, rest: rest})

    ~H"""
    <span class="inline-flex">
      <.intersperse :let={field_name} enum={@rest}>
        <:separator>
          <span>,&nbsp;</span>
        </:separator>

        <span class="font-bold"><%= field_name %></span>
      </.intersperse>

      <span :if={not Enum.empty?(@rest)}>&nbsp;<%= @filter.operation %>&nbsp;</span>

      <span :if={not is_nil(@last)} class="font-bold"><%= @last %></span>
    </span>
    """
  end
end
