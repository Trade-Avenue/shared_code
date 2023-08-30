defmodule FeedbackCupcakeWeb.Components.Sidebar.Container do
  @moduledoc false

  use FeedbackCupcakeWeb, :html

  slot :group, doc: "container split by groups"

  def render(assigns) do
    assigns =
      assigns
      |> assign_new(:group, fn -> [] end)

    ~H"""
    <div class="flex flex-col gap-5">
      <%= for group <- @group do %>
        <nav>
          <h3 class="pl-3 mb-3 text-xs font-semibold leading-6 text-gray-400 uppercase">
            <%= group.text %>
          </h3>
          <%= render_slot(group) %>
        </nav>
      <% end %>
    </div>
    """
  end
end
