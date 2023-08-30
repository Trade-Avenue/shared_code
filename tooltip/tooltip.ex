defmodule FeedbackCupcakeWeb.Components.Tooltip do
  @moduledoc false

  use FeedbackCupcakeWeb, :html

  attr :id, :string
  attr :content, :string, required: true

  attr :theme, :string, default: "translucent"
  attr :animation, :string, default: "scale"

  attr :skidding, :integer, default: nil
  attr :distance, :integer, default: nil

  attr :show_arrow, :boolean, default: true

  slot :inner_block

  def simple(assigns) do
    assigns = maybe_generate_id(assigns)

    ~H"""
    <span
      id={@id}
      phx-hook="TippyHook"
      data-type="simple"
      data-content={@content}
      data-theme={@theme}
      data-animation={@animation}
      data-skidding={@skidding}
      data-distance={@distance}
      data-show_arrow={"#{@show_arrow}"}
    >
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  attr :id, :string

  attr :theme, :string, default: "translucent"
  attr :animation, :string, default: "scale"
  attr :show_arrow, :boolean, default: true

  slot :inner_block
  slot :content, required: true

  def with_html_content(assigns) do
    assigns = maybe_generate_id(assigns)

    ~H"""
    <span
      id={@id}
      phx-hook="TippyHook"
      data-type="html_content"
      data-theme={@theme}
      data-animation={@animation}
      data-show_arrow={"#{@show_arrow}"}
    >
      <div id={@id <> "-html-content"}>
        <%= render_slot(@content) %>
      </div>

      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  defp maybe_generate_id(%{id: _} = assigns), do: assigns

  defp maybe_generate_id(assigns) do
    id = :erlang.unique_integer([:positive, :monotonic]) |> to_string() |> then(&"tooltip-#{&1}")

    Map.put(assigns, :id, id)
  end
end
