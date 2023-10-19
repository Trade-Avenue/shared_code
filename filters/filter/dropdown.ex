defmodule CoreWeb.Components.Filter.Dropdown do
  @moduledoc false

  alias CoreWeb.Components.Tooltip

  use CoreWeb, :html

  attr :id, :string, required: true

  attr :builder, AshQueryBuilder, required: true, doc: "The query builder."

  slot :filter, required: true

  def render(assigns) do
    %{builder: %{filters: filters}} = assigns

    assigns = assign(assigns, filters_count: filters_count(filters))

    ~H"""
    <div>
      <.dropdown js_lib="live_view_js" options_container_id={@id} menu_items_wrapper_class="w-max">
        <:trigger_element>
          <Tooltip.simple content="Apply filters">
            <div class="pc-button--light-outline pc-button--md pc-button--with-icon pc-button">
              <span class="hidden md:inline md:mr-2">Filters</span>
              <span class="pc-tab__number pc-tab__number__underline--is-active mx-0 px-1.8 py-0.4">
                <%= @filters_count %>
              </span>
              <Heroicons.funnel class="w-5 h-5 ml-2 -mr-1" />
            </div>
          </Tooltip.simple>
        </:trigger_element>

        <div class="flex flex-col gap-4 p-4">
          <%= for filter <- @filter do %>
            <%= render_slot(filter, @builder) %>
          <% end %>
        </div>
      </.dropdown>
    </div>
    """
  end

  defp filters_count(filters), do: filters |> Enum.map(&filter_count/1) |> Enum.sum()

  defp filter_count(%AshQueryBuilder.FilterScope{filters: filters}) do
    if Enum.any?(filters, & &1.enabled?), do: 1, else: 0
  end

  defp filter_count(%{enabled?: true}), do: 1
  defp filter_count(%{enabled?: false}), do: 0
end
