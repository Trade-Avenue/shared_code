defmodule FeedbackCupcakeWeb.Components.Notification.Disconnected do
  @moduledoc false

  alias FeedbackCupcakeWeb.Components.Notification.{Component, Helpers}

  use FeedbackCupcakeWeb, :html

  use TypedStruct

  typedstruct enforce: true do
    field :component, Component.t()
  end

  @spec new(Component.t()) :: t
  def new(component \\ Component.new(&render/1)), do: struct!(__MODULE__, component: component)

  attr :key, :string, required: true
  attr :notification, __MODULE__, required: true

  attr :rest, :global

  def render(assigns) do
    ~H"""
    <div
      id={@key}
      class={Helpers.notification_classes()}
      phx-hook="DisconnectedNotificationHook"
      data-hide={Helpers.hide_notification(@key)}
      data-show={Helpers.show_notification(@key)}
      {@rest}
    >
      <.alert with_icon color="danger" heading="We can't find the internet">
        Attempting to reconnect <Heroicons.arrow_path class="ml-1 w-3 h-3 inline animate-spin" />
      </.alert>
    </div>
    """
  end
end

defimpl FeedbackCupcakeWeb.Components.Notification.Protocol,
  for: FeedbackCupcakeWeb.Components.Notification.Disconnected do
  def module(notification), do: notification.component.module

  def function_name(notification), do: notification.component.function_name
end
