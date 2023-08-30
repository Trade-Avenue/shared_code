defmodule FeedbackCupcakeWeb.Components.LocalTime do
  @moduledoc false

  use FeedbackCupcakeWeb, :html

  attr :id, :string
  attr :date_time, :any, required: true

  def simple(assigns) do
    assigns = maybe_generate_id(assigns)

    ~H"""
    <time id={@id} datetime={@date_time} phx-hook="LocalTimeHook" />
    """
  end

  defp maybe_generate_id(%{id: _} = assigns), do: assigns
  defp maybe_generate_id(assigns), do: Map.put(assigns, :id, Ecto.UUID.generate())
end
