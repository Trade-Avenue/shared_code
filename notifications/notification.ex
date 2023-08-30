defmodule FeedbackCupcakeWeb.Components.Notification do
  @moduledoc false

  alias FeedbackCupcakeWeb.Components.Notification

  alias Phoenix.{LiveView, LiveView.Socket}

  @spec put_notification(Socket.t(), Notification.Protocol.t()) :: Socket.t()
  def put_notification(socket, notification) do
    key =
      :erlang.unique_integer([:positive, :monotonic])
      |> to_string()
      |> then(&"notification-#{&1}")

    LiveView.put_flash(socket, key, notification)
  end
end
