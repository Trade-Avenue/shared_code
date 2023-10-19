defmodule CoreWeb.Components.Form.GenderTextField.Badge do
  @moduledoc false

  use CoreWeb, :html

  attr :auto_gen?, :boolean, required: true

  def render(assigns) do
    ~H"""
    <div class="absolute right-4 pt-2">
      <.badge class={"h-6 gap-1 #{auto_gen(@auto_gen?)}"}>
        <%= if @auto_gen?, do: "Generating...", else: "Manual" %>
        <Heroicons.cog class={"#{if @auto_gen?, do: "animate-spin", else: "" } w-5 h-5"} />
      </.badge>
    </div>
    """
  end

  defp auto_gen(true) do
    "text-blue-800 dark:border-blue-200"
  end

  defp auto_gen(_) do
    "text-pink-800 bg-pink-200 border-pink-200 dark:text-pink-800 dark:bg-pink-200 dark:border-pink-200"
  end
end
