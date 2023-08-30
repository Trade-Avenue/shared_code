defmodule FeedbackCupcakeWeb.Components.Filter.Descriptions.NotEqual do
  @moduledoc false

  alias FeedbackCupcakeWeb.Components.Filter.Descriptions.Helper

  use FeedbackCupcakeWeb, :html

  def value_part(%{filter: filter} = assigns) do
    assigns = assign(assigns, value: Helper.filter_value(filter))

    ~H"""
    is different than <span class="font-bold"><Helper.convert_value value={@value} /></span>
    """
  end
end
