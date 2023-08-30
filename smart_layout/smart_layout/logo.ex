defmodule FeedbackCupcakeWeb.Components.SmartLayout.Logo do
  @moduledoc false

  use FeedbackCupcakeWeb, :html

  # TODO: We can make improvement on link part if necessary

  attr :src, :string, required: true
  attr :dark_src, :string, default: ""
  attr :path, :string, default: ""

  def render(assigns) do
    ~H"""
    <.a to={@path}>
      <.logo light_src={@src} dark_src={@dark_src} />
    </.a>
    """
  end

  attr :light_src, :string, required: true
  attr :dark_src, :string, default: ""

  defp logo(assigns) do
    %{dark_src: dark_src, light_src: light_src} = assigns

    dark_src = if dark_src == "", do: light_src, else: dark_src

    assigns = assign(assigns, dark_src: dark_src)

    ~H"""
    <img class="h-14 block dark:hidden" src={@light_src} />
    <img class="h-14 hidden dark:block" src={@dark_src} />
    """
  end
end
