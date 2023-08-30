defmodule FeedbackCupcakeWeb.Components.Sidebar.Group do
  @moduledoc false

  use FeedbackCupcakeWeb, :html

  slot :inner_block, doc: "group content"

  def render(assigns) do
    assigns =
      assigns
      |> assign_new(:inner_block, fn -> [] end)

    ~H"""
    <div class="divide-y divide-gray-300">
      <div class="space-y-1">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
