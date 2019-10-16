defmodule Snor.Utils do
  def deep_get(_data, <<>>, default), do: default

  def deep_get(data, path, default) do
    case String.split(path, <<46>>) do
      [key] -> Map.get(data, key, default)
      keys -> get_in(data, keys)
    end
  end

  def deep_stringify(map) do
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
