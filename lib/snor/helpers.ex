defmodule Snor.Helpers do
  require Logger
  alias Snor.Utils

  def upcase(scope, args) do
    item = Map.get(args, "item")
    String.upcase(Snor.NewParser.render(item, scope))
  end

  @spec multiply(any(), map()) :: integer()
  def multiply(_scope, opts) do
    opts
    |> Map.values()
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(1, &(&1 * &2))
  end
end
