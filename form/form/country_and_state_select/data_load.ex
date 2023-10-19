defmodule CoreWeb.Components.Form.CountryAndStateSelect.DataLoad do
  @moduledoc false

  alias Core.Utils.CountriesAndStates

  def initial_load(country, state) do
    countries = CountriesAndStates.iso_3_countries() |> add_empty_option("Select a country")

    country = countries |> find_country_option(country) |> elem(1)

    states = country |> CountriesAndStates.states() |> add_empty_option("Select a state")

    state = states |> find_state_option(state) |> elem(1)

    %{countries: countries, states: states, country: country, state: state}
  end

  def load_states(country_iso_3) do
    states = country_iso_3 |> CountriesAndStates.states() |> add_empty_option("Select a state")

    state = states |> find_state_option(nil) |> elem(1)

    %{states: states, state: state}
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
