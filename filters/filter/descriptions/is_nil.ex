defmodule FeedbackCupcakeWeb.Components.Filter.Descriptions.IsNil do
  @moduledoc false

  use FeedbackCupcakeWeb, :html

  def value_part(assigns) do
    ~H"""
    is empty
    """
  end
end
