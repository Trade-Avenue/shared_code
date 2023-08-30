defmodule FeedbackCupcakeWeb.Components.Form.CountryAndStateSelect.DataLoad do
  @moduledoc false

  alias FeedbackCupcake.Utils.CountriesAndStates

  alias Phoenix.LiveView

  def async_initial_load(id, component_module, country, state, pid \\ self()) do
    Task.async(fn ->
      countries = CountriesAndStates.iso_3_countries() |> add_empty_option("Select a country")

      country = countries |> find_country_option(country) |> elem(1)

      states = country |> CountriesAndStates.states() |> add_empty_option("Select a state")

      state = states |> find_state_option(state) |> elem(1)

      LiveView.send_update(pid, component_module,
        id: id,
        task: self(),
        operation: :initial_load,
        countries: countries,
        country: country,
        states: states,
        state: state
      )

      :ok
    end)
  end

  def async_load_states(id, component_module, country_iso_3, pid \\ self()) do
    Task.async(fn ->
      states = country_iso_3 |> CountriesAndStates.states() |> add_empty_option("Select a state")

      state = states |> find_state_option(nil) |> elem(1)

      LiveView.send_update(pid, component_module,
        id: id,
        task: self(),
        operation: :states_load,
        states: states,
        state: state
      )

      :ok
    end)
  end

  defp add_empty_option(options, empty_option_label), do: [{empty_option_label, nil} | options]

  defp find_country_option(options, country_iso_2) do
    case Enum.find(options, fn {_, iso_2} -> iso_2 == country_iso_2 end) do
      nil -> List.first(options)
      option -> option
    end
  end

  defp find_state_option(options, state_code) do
    case Enum.find(options, fn {_, code} -> code == state_code end) do
      nil -> List.first(options)
      option -> option
    end
  end
end
