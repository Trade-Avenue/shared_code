defmodule CoreWeb.Components.Form.GenderTextField do
  @moduledoc false

  alias CoreWeb.Components.Form.GenderTextField.{
    Field,
    Switch,
    Badge,
    GenButton
  }

  use CoreWeb, :live_component

  attr :id, :any, required: true, doc: "The component unique id."

  def live_render(assigns), do: ~H"<.live_component module={__MODULE__} {assigns} />"

  def update(assigns, socket) do
    socket =
      socket
      |> assign_new(:auto_gen?, fn -> true end)
      |> assign_new(:auto_male?, fn -> false end)
      |> assign_new(:auto_female?, fn -> true end)
      |> assign_new(:form, fn -> to_form(%{}) end)
      |> assign(assigns)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="dark:text-white text-black">
      <div class="flex flex-col md:flex md:flex-row" id={"text-field-container-#{@id}"}>
        <div class="md:w-1/2">
          <Field.render
            id={"male-field-#{@id}"}
            disabled={@auto_gen? and @auto_male?}
            field={@form[:male]}
            label="Male"
            target={@myself}
            change="validate"
          />
        </div>

        <Switch.render
          parent_id={@id}
          target={@myself}
          click_on={&switch_female_male/1}
          click_off={&switch_male_female/1}
        />

        <div class="md:w-1/2">
          <Badge.render auto_gen?={@auto_gen?} />

          <Field.render
            id={"female-field-#{@id}"}
            disabled={@auto_gen? and @auto_female?}
            field={@form[:female]}
            label="Female"
            target={@myself}
            change="validate"
          />
        </div>
      </div>
      <div class="flex flex-row-reverse gap-2">
        <GenButton.render auto_gen?={@auto_gen?} target={@myself} />
      </div>
    </div>
    """
  end

  def handle_event("validate", params, socket) do
    socket = handle_generation(socket, params)
    {:noreply, socket}
  end

  def handle_event("toggle_auto_gen", _params, socket) do
    %{auto_gen?: auto_gen?} = socket.assigns
    %{params: params} = socket.assigns.form

    socket = assign(socket, auto_gen?: not auto_gen?) |> handle_generation(params)

    {:noreply, socket}
  end

  def handle_event("submit_to_cursor", params, socket) do
    {:noreply, socket}
  end

  def handle_event("submit", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("switch_gender", _params, socket) do
    socket = do_switch_gender(socket)

    {:noreply, socket}
  end

  defp generate(%{"male" => male} = params) do
    female = TextMorph.convert_to_female(male)

    Map.put(params, "female", female)
  end

  defp generate(%{"female" => female} = params) do
    male = TextMorph.convert_to_male(female)

    Map.put(params, "male", male)
  end

  defp do_switch_gender(socket) do
    %{auto_male?: auto_male?, auto_female?: auto_female?} = socket.assigns

    socket
    |> assign(auto_male?: not auto_male?)
    |> assign(auto_female?: not auto_female?)
  end

  defp handle_generation(%{assigns: %{auto_gen?: true}} = socket, params) do
    %{auto_male?: auto_male?, auto_female?: auto_female?} = socket.assigns

    params =
      params
      |> validate_params(auto_female?, auto_male?)
      |> generate()

    assign(socket, form: to_form(params))
  end

  defp handle_generation(socket, params) do
    assign(socket, form: update_form(socket.assigns.form, params))
  end

  defp update_form(form, params) do
    %{params: form_params} = form

    form_params
    |> update_male_form(Map.get(params, "male"))
    |> update_female_form(Map.get(params, "female"))
    |> to_form
  end

  defp update_male_form(source, params) when is_nil(params), do: source

  defp update_male_form(source, params), do: %{source | "male" => params}

  defp update_female_form(source, params) when is_nil(params), do: source

  defp update_female_form(source, params), do: %{source | "female" => params}

  defp validate_params(params, _male = true, _female = false),
    do: %{"male" => params["male"] || ""}

  defp validate_params(params, _male = false, _female = true),
    do: %{"female" => params["female"] || ""}

  defp switch_female_male(js \\ %JS{}, id) do
    js
    |> JS.remove_class("md:flex-row flex-col", to: "#text-field-container-#{id}")
    |> JS.add_class("md:flex-row-reverse flex-col-reverse", to: "#text-field-container-#{id}")
    |> JS.hide()
    |> JS.show(to: "#male-female-button-#{id}")
    |> JS.push("switch_gender")
  end

  defp switch_male_female(js \\ %JS{}, id) do
    js
    |> JS.add_class("md:flex-row flex-col", to: "#text-field-container-#{id}")
    |> JS.remove_class("md:flex-row-reverse flex-col-reverse", to: "#text-field-container-#{id}")
    |> JS.hide()
    |> JS.show(to: "#female-male-button-#{id}")
    |> JS.push("switch_gender")
  end
end
