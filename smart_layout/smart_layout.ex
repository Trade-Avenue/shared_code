defmodule FeedbackCupcakeWeb.Components.SmartLayout do
  @moduledoc false

  alias FeedbackCupcakeWeb.Components.SmartLayout.{Layout, LightSwitchButton}

  defdelegate layout(assigns), to: Layout, as: :render

  defdelegate switch_button(assigns), to: LightSwitchButton, as: :render
end
