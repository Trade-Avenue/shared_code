defmodule CoreWeb.Components.Form.Select do
  @moduledoc false

  alias CoreWeb.Components.Helpers.Target

  use CoreWeb, :live_component

  attr :id, :any, required: true, doc: "The component unique id."

  attr :target, Target, default: nil

  attr :searchable?, :boolean, default: true
  attr :search_placeholder, :string, default: "Search"

  attr :search_element_query, :string,
    default: nil,
    doc: "The CSS selector query to find the option element where the option text is."

  attr :options, :list, required: true, doc: "The options list."
  attr :default_option, :string, required: true

  attr :rest, :global

  slot :trigger_element, required: true
  slot :option_element, required: true
  slot :empty_list_element

  def live_render(assigns), do: ~H"<.live_component module={__MODULE__} {assigns} />"

  def update(assigns, socket) do
    %{id: id, default_option: default_option} = assigns

    assigns = Map.drop(assigns, [:default_option])

    socket =
      socket
      |> assign(assigns)
      |> maybe_assign_form(to_form(%{"value" => default_option}))
      |> maybe_push_change_button_to_default_option(id, default_option)
      |> assign(initialized?: true)

    {:ok, socket}
  end

  def handle_event("update", %{"value" => "empty_option"}, socket),
    do: handle_event("update", %{"value" => nil}, socket)

  def handle_event("update", params, socket) do
    %{id: id, target: target} = socket.assigns

    form = to_form(params)

    Target.send_message(%{operation: :updated_value, from: id, value: form[:value].value}, target)

    {:noreply, assign(socket, form: form)}
  end

  defp maybe_assign_form(%{assigns: %{form: form}} = socket, form), do: socket
  defp maybe_assign_form(socket, form), do: assign(socket, form: form)

  defp empty_options?([{_, nil} | rest]), do: Enum.empty?(rest)
  defp empty_options?(options), do: Enum.empty?(options)

  defp maybe_push_change_button_to_default_option(
         %{assigns: %{initialized?: true}} = socket,
         _,
         _
       ),
       do: socket

  defp maybe_push_change_button_to_default_option(socket, id, default_option) do
    push_event(socket, "js-exec", %{
      to: default_option_id(id, default_option),
      attr: "phx-mounted"
    })
  end

  defp default_option_id(id, nil), do: "##{id}-empty-option"
  defp default_option_id(id, default_option), do: "##{id}-#{default_option}"
end
