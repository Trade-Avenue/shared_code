defmodule FeedbackCupcakeWeb.Components.Loading do
  @moduledoc false

  alias FeedbackCupcakeWeb.Components.Icon

  use FeedbackCupcakeWeb, :html

  attr :class, :string, default: ""

  def dots(assigns) do
    ~H"""
    <div class="w-fit flex items-center justify-center space-x-2">
      <Icon.cupcake class={"animate-bounce fill-black #{@class}"} />
      <Icon.cupcake class={"animate-bounce animation-delay-200 fill-black #{@class}"} />
      <Icon.cupcake class={"animate-bounce animation-delay-400 fill-black #{@class}"} />
    </div>
    """
  end

  attr :icon_class, :string, default: ""

  attr :text, :string, default: "Loading..."
  attr :text_class, :string, default: ""

  def dots_with_text(assigns) do
    ~H"""
    <div class="w-fit text-center">
      <.dots class={@icon_class} />
      <span class={@text_class}><%= @text %></span>
    </div>
    """
  end
end
