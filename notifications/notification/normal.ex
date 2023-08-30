defmodule FeedbackCupcakeWeb.Components.Notification.Normal do
  @moduledoc false

  alias FeedbackCupcakeWeb.Components.Notification.{Component, Options, Helpers}

  use FeedbackCupcakeWeb, :html

  use TypedStruct

  @type type :: :info | :success | :warning | :danger

  typedstruct enforce: true do
    field :type, type
    field :message, String.t()

    field :options, Options.t()

    field :component, Component.t()
  end

  @spec new(type, String.t(), Options.t(), Component.t()) :: t
  def new(type, message, options, component \\ Component.new(&render/1)),
    do: struct!(__MODULE__, type: type, message: message, options: options, component: component)

  attr :key, :string, required: true
  attr :notification, __MODULE__, required: true

  attr :rest, :global

  def render(assigns) do
    ~H"""
    <div
      id={@key}
      class={Helpers.notification_classes()}
      phx-hook="FlashHook"
      phx-mounted={Helpers.show_notification(@key)}
      data-hide={Helpers.hide_notification(@key)}
      data-show={Helpers.show_notification(@key)}
      data-dismissible={"#{@notification.options.dismissible?}"}
      data-dismiss-time={@notification.options.dismiss_time}
      {@rest}
    >
      <.alert
        with_icon
        close_button_properties={close_button_properties(@notification.options, @key)}
        color={color(@notification.type)}
        class="relative overflow-hidden"
      >
        <span><%= Phoenix.HTML.raw(@notification.message) %></span>

        <.progress_bar :if={@notification.options.dismissible?} id={"#{@key}-progress"} />
      </.alert>
    </div>
    """
  end

  attr :id, :string, required: true

  defp progress_bar(assigns) do
    ~H"""
    <div id={@id} class="absolute bottom-0 left-0 h-1 bg-black/10" style="width: 0%" />
    """
  end

  defp color(type), do: to_string(type)

  defp close_button_properties(%{closable?: true}, key),
    do: ["phx-click": JS.exec("data-hide", to: "##{key}")]

  defp close_button_properties(%{closable?: false}, _), do: nil
end

defimpl FeedbackCupcakeWeb.Components.Notification.Protocol,
  for: FeedbackCupcakeWeb.Components.Notification.Normal do
  def module(notification), do: notification.component.module

  def function_name(notification), do: notification.component.function_name
end
