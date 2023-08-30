defmodule FeedbackCupcakeWeb.Components.Table.Header do
  @moduledoc false

  use FeedbackCupcakeWeb, :html

  import PhxComponentHelpers

  attr :class, :string, default: ""

  slot :inner_block

  def normal(assigns) do
    assigns = extend_class(assigns, "pc-table__th text-slate-600")

    ~H"""
    <th {@heex_class}>
      <%= render_slot(@inner_block) %>
    </th>
    """
  end
end
