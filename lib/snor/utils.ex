defmodule Snor.Utils do
  @moduledoc """
  Util functions to be used internally
  """

  def deep_get(_data, <<>>, default), do: default

  @doc """
  Get a deeply nested value from a map

  ## Examples

      iex> Snor.Utils.deep_get(%{"a" => 1}, "a", "")
      1
      iex> Snor.Utils.deep_get(%{"a" => %{"b" => :ok}}, "a.b", :error)
      :ok
      iex> Snor.Utils.deep_get(%{}, "a.b", "NOT_FOUND")
      "NOT_FOUND"

  """
  @spec deep_get(map(), String.t(), any()) :: any()
  def deep_get(data, path, default) do
    case String.split(path, <<46>>) do
      [key] -> Map.get(data, key, default)
      keys -> get_in(data, keys) || default
    end
  end

  @doc """
  Given a map, stringify all the keys

  ## Examples

      iex> Snor.Utils.deep_stringify(%{})
      %{}
      iex> Snor.Utils.deep_stringify(%{a: 4})
      %{"a" => 4}
      iex> Snor.Utils.deep_stringify(%{a: [%{b: 1}]})
      %{"a" => [%{"b" => 1}]}

  """
  def deep_stringify(map) do
    case is_list(map) do
      true ->
        Enum.map(map, &deep_stringify/1)

      false ->
        case is_map(map) do
          false ->
            map

          true ->
            map
            |> Enum.map(fn {key, value} ->
              case is_atom(key) do
                false -> {key, deep_stringify(value)}
                true -> {Atom.to_string(key), deep_stringify(value)}
              end
            end)
            |> Enum.into(%{})
        end
    end
  end
end
