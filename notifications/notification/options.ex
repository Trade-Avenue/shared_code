defmodule FeedbackCupcakeWeb.Components.Notification.Options do
  @moduledoc false

  use TypedStruct

  typedstruct do
    field :dismissible?, boolean, default: true
    field :dismiss_time, :pos_integer, default: :timer.seconds(10)

    field :closable?, boolean, default: true
  end

  @spec new(Keyword.t()) :: t
  def new(options \\ []), do: struct!(__MODULE__, options)
end
