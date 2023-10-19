defmodule CoreWeb.Components.Filter.Descriptions.IsNil do
  @moduledoc false

  use CoreWeb, :html

  def value_part(assigns) do
    ~H"""
    is empty
    """
  end
end
