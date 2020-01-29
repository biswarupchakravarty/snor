defmodule Snor.Helpers do
  @moduledoc """
  Basic set of helpers.

  This out of the box helpers module is fairly useless, and is expected that
  the user injects their own helpers.
  """
  require Logger
  alias Snor.Utils

  def upcase(_scope, args) do
    args
    |> Map.get("item")
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
