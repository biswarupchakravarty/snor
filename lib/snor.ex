defmodule Snor do
  @moduledoc """
  Snor is a fast and simple implementation of Mustache style templating for Elixir.

  Snor also has support for executing functions.
  """
  alias Snor.{Executor, Parser}

  @doc ~S"""
  Render a given template to a string. The second parameter is the map that
  contains the data to use for interpolation. The third parameter is the
  module to use for looking up the helper functions.

  ## Examples
      iex> Snor.process("Hello {{name}}", %{name: "World"})
      "Hello World"

      iex> Snor.process("Hello")
      "Hello"
  """
  @spec process(String.t(), map(), module() | nil) :: String.t()
  def process(input, data \\ %{}, _helpers \\ nil) do
    {:ok, tokens, "", %{}, _, _} = Parser.parse_binary(input)
    Executor.execute(tokens, stringify(data))
  end

  defp stringify(map) when is_map(map) do
    map
    |> Enum.map(fn {k, v} ->
      case k do
        atom when is_atom(atom) -> {Atom.to_string(k), stringify(v)}
        s when is_binary(s) -> {k, stringify(v)}
        _ -> raise "Only atoms and strings are allowed values in data!"
      end
    end)
    |> Enum.into(%{})
  end

  defp stringify(x), do: x
end
