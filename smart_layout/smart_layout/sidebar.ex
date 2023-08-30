defmodule FeedbackCupcakeWeb.Components.SmartLayout.Sidebar do
  @moduledoc false

  alias FeedbackCupcakeWeb.Components.Sidebar.{Button, Container, Group}

  defdelegate button(assigns), to: Button, as: :render

  defdelegate container(assigns), to: Container, as: :render

  defdelegate group(assigns), to: Group, as: :render
end
