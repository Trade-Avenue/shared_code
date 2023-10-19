defmodule CoreWeb.Components.Form.CountryAndStateSelect.CountryImages do
  @moduledoc false

  def path(nil), do: nil
  def path(country), do: "/images/countries/#{country}.svg"
end
