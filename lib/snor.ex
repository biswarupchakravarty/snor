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
      iex> Snor.render("Hello {{name}}", %{name: "World"})
      "Hello World"

      iex> Snor.render("Hello")
      "Hello"
  """
  @spec render(String.t(), map(), module()) :: String.t()
  def render(string, data \\ %{}, helpers \\ Snor.Helpers) do
    string
    |> Parser.parse()
    |> Executor.execute(data, helpers)
  end
end
