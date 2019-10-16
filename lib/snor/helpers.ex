defmodule Snor.Helpers do
  require Logger
  alias Snor.Utils

  def upcase(scope, item) do
    case Map.has_key?(scope, item) do
      true -> Map.get(scope, item)
      false -> Utils.deep_get(scope, item, item)
    end
    |> String.upcase()
  end

  @spec multiply(any(), map()) :: integer()
  def multiply(_scope, opts) do
    opts
    |> Map.values()
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(1, &(&1 * &2))
  end
end
