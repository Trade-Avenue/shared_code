defmodule CoreWeb.Components.Filter.Descriptions.LessThanOrEqual do
  @moduledoc false

  alias CoreWeb.Components.Filter.Descriptions.Helper

  use CoreWeb, :html

  def value_part(%{filter: filter} = assigns) do
    assigns = assign(assigns, value: Helper.filter_value(filter))

    ~H"""
    is less than or equal to <span class="font-bold"><Helper.convert_value value={@value} /></span>
    """
  end
end
