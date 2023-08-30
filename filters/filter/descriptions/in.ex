defmodule FeedbackCupcakeWeb.Components.Filter.Descriptions.In do
  @moduledoc false

  alias FeedbackCupcakeWeb.Components.Filter.Descriptions.Helper

  use FeedbackCupcakeWeb, :html

  def value_part(%{filter: filter} = assigns) do
    {last, rest} = filter |> Helper.filter_value() |> List.pop_at(-1)

    assigns = assign(assigns, %{last: last, rest: rest})

    ~H"""
    is
    <span class="inline-flex">
      <.intersperse :let={value} enum={@rest}>
        <:separator>
          <span>,&nbsp;</span>
        </:separator>

        <span class="font-bold"><Helper.convert_value value={
          value
        } /></span>
      </.intersperse>

      <span :if={not Enum.empty?(@rest)}>
        &nbsp;or&nbsp;
      </span>

      <span
        :if={not is_nil(@last)}
        class="font-bold"
      ><Helper.convert_value value={@last} /></span>
    </span>
    """
  end
end
