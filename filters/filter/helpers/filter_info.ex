defmodule FeedbackCupcakeWeb.Components.Filter.Helpers.FilterInfo do
  @moduledoc """
  A struct to be used for storing filter information for `AshQueryBuilder`.
  """

  use TypedStruct

  typedstruct enforce: true do
    field :id, String.t()

    field :field, atom
    field :path, [atom], default: []
  end

  @spec new(String.t(), [atom], atom) :: t
  def new(id, path \\ [], field), do: struct!(__MODULE__, id: id, path: path, field: field)
end
