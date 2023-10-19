defmodule CoreWeb.Components.Filter.Descriptions.Helper do
  @moduledoc false

  alias CoreWeb.Components.LocalTime

  use CoreWeb, :html

  def maybe_get_name_from_map(key, path, names) when is_map_key(names, {key, path}),
    do: Map.fetch!(names, {key, path})

  def maybe_get_name_from_map(key, _, _),
    do: key |> Atom.to_string() |> String.replace("_", " ") |> String.capitalize()

  def filter_value(%{metadata: %{value_name: value}}), do: value
  def filter_value(%{value: value}), do: value

  def convert_value(%{value: %DateTime{}} = assigns) do
    ~H"""
    <LocalTime.simple date_time={@value} />
    """
  end

  def convert_value(assigns), do: ~H"<%= @value %>"
end
