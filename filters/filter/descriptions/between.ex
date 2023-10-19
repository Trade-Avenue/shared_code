defmodule CoreWeb.Components.Filter.Descriptions.Between do
  @moduledoc false

  alias CoreWeb.Components.Filter.Descriptions.Helper

  use CoreWeb, :html

  def value_part(%{filter: filter} = assigns) do
    [min, max] = values(filter)

    assigns = assign(assigns, %{min: min, max: max})

    do_value_part(assigns)
  end

  defp do_value_part(%{min: nil} = assigns) do
    ~H"""
    is less than or equal to <span class="font-bold"><Helper.convert_value value={@max} /></span>
    """
  end

  defp do_value_part(%{max: nil} = assigns) do
    ~H"""
    is greater than or equal to <span class="font-bold"><Helper.convert_value value={@min} /></span>
    """
  end

  defp do_value_part(assigns) do
    ~H"""
    is between <span class="font-bold"><Helper.convert_value value={@min} /></span>
    and <span class="font-bold"><Helper.convert_value value={@max} /></span>
    """
  end

  defp values(%{metadata: %{min: min, max: max}}), do: [min, max]
  defp values(filter), do: Helper.filter_value(filter)
end
