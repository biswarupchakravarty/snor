defmodule Snor.Parser do
  @moduledoc """
  Convert a string into an intermediate representation - a list of nodes.

  A node could be one of (mainly) -

  - A raw value, which is a verbatim string
  - An value to be interpolated
  - A custom function to be called, and the arguments
  """

  @type template_node :: any()

  @doc """
  Parse a string into a list of nodes
  """
  @spec parse(binary()) :: [template_node()]
  def parse(<<string::binary>>), do: parse(string, string, 0, 0, false, false, [])

  defp parse(string, <<>>, marker, pointer, _, _, tokens),
    do: add_raw_token(string, marker, pointer, tokens)

  # opening tag
  defp parse(string, <<123, 123, rest::binary>>, marker, pointer, _is_open, _is_function, tokens)
       when pointer < 2,
       do: parse(string, rest, marker, pointer + 2, true, false, tokens)

  # opening tag
  defp parse(string, <<123, 123, rest::binary>>, marker, pointer, _is_open, _is_function, tokens) do
    parse(
      string,
      rest,
      pointer,
      pointer + 2,
      true,
      false,
      add_raw_token(string, marker, pointer, tokens)
    )
  end

  # closing tag
  defp parse(string, <<125, 125, rest::binary>>, marker, pointer, true, is_function, tokens) do
    parse(
      string,
      rest,
      pointer + 2,
      pointer + 2,
      false,
      false,
      add_node_token(binary_part(string, marker + 2, pointer - (marker + 2)), is_function, tokens)
    )
  end

  defp parse(string, <<32, rest::binary>>, marker, pointer, true, _, tokens) do
    parse(string, rest, marker, pointer + 1, true, true, tokens)
  end

  defp parse(string, <<_, rest::binary>>, marker, pointer, is_open, is_function, tokens) do
    parse(string, rest, marker, pointer + 1, is_open, is_function, tokens)
  end

  defp add_node_token(token, true, tokens),
    do: [add_function_token(token) | tokens]

  defp add_node_token(token, false, tokens),
    do: [%{type: :data, val: token} | tokens]

  defp add_raw_token(string, from, to, tokens) when to - from > 0,
    do: [%{type: :raw, val: binary_part(string, from, to - from)} | tokens]

  defp add_raw_token(_string, _from, _to, tokens), do: tokens

  @supported Snor.Helpers.__info__(:functions)
             |> Enum.map(fn {f, a} -> {to_string(f), a} end)
             |> Enum.into(%{})

  defp add_function_token(token) do
    [fn_name | tokens] = String.split(token, <<32>>)

    case Map.get(@supported, fn_name) do
      nil ->
        raise "NotFound[#{fn_name}]"

      arity ->
        # check for presence of =
        case String.contains?(hd(tokens), <<61>>) do
          true ->
            map =
              tokens
              |> Enum.join(<<32>>)
              |> String.split([<<32>>])
              |> Enum.map(fn pair ->
                [key, val] = String.split(pair, <<61>>)
                {key, val}
              end)
              |> Enum.into(%{})

            %{type: :fn, function: String.to_atom(fn_name), args: [map]}

          false ->
            case length(tokens) == arity - 1 do
              true ->
                %{type: :fn, function: String.to_atom(fn_name), args: tokens}

              false ->
                raise "MismatchedArgs[#{fn_name}][#{length(tokens)} instead of #{arity - 1}]"
            end
        end
    end
  end
end
