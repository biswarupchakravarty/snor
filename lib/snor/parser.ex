defmodule Snor.Parser do
  @moduledoc """
  Convert a string into an intermediate representation - a list of nodes.

  A node could be one of (mainly) -

  - A plaintext node
  - A function node
  - A block node
  """

  @typedoc """
  A parsed node
  """
  @type parsed_node :: plaintext_node() | interpolation_node() | block_node() | function_node()

  @typedoc "A grapheme from the template that was passed in"
  @type token :: String.grapheme()

  @typedoc "Represents remaining tokens after a node was parsed and extracted"
  @type remaining_tokens :: [token]

  @typedoc "A block node"
  @type block_node :: %{with_scope: String.t(), children: [parsed_node()], negative: boolean()}

  @typedoc "A plaintext node"
  @type plaintext_node :: %{plaintext: String.t()}

  @typedoc "An interpolation node"
  @type interpolation_node :: %{interpolation: String.t()}

  @typedoc "An argument pair"
  @type argument_pair :: %{key: String.t(), value: [parsed_node]}

  @typedoc "A function node"
  @type function_node :: %{function: String.t(), arguments: [argument_pair]}

  @typedoc "The result of a `parse_*` operation"
  @type parse_result :: {:error, String.t()} | {:ok, parsed_node, remaining_tokens()}

  @doc ~S"""
  Parse a string into a list of nodes

  ## Examples

      iex> Snor.Parser.parse("Hello")
      [%{plaintext: "Hello"}]

      iex> Snor.Parser.parse("{{name}}")
      [%{interpolation: "name"}]

      iex> Snor.Parser.parse("{{upcase item='Jane'}}")
      [%{arguments: [%{key: "item", value: [%{plaintext: "Jane"}]}], function: "upcase"}]

      iex> Snor.Parser.parse("{{#person}}{{name}}{{/person}}")
      [%{children: [%{interpolation: "name"}, %{plaintext: ""}], negative: false, with_scope: "person"}]
  """
  @spec parse(String.t()) :: [parsed_node]
  def parse(template) do
    result =
      template
      |> String.graphemes()
      |> process([], [], nil)

    case result do
      {nodes, []} -> nodes
      {_, unprocessed} -> raise "Unprocessed #{inspect(unprocessed)}"
    end
  end

  @doc "Parse an interpolation/block node"
  @spec parse_node([token], [parsed_node]) ::
          {:error, String.t()} | {:ok, parsed_node, remaining_tokens()}
  def parse_node(tokens, nodes),
    do: maybe([:interpolation, :block], tokens, nodes)

  @doc "Parse a block"
  @spec parse_block([token], [parsed_node()]) :: parse_result
  def parse_block(tokens, _nodes) do
    init = %{negative: false, buffer: [], tokens: tokens}

    result =
      Enum.reduce_while(tokens, init, fn c, acc ->
        %{buffer: buffer, tokens: [_ | remaining]} = acc

        case c do
          "^" ->
            {:cont, %{acc | negative: true, tokens: remaining}}

          "#" ->
            {:cont, %{acc | tokens: remaining}}

          "}" ->
            case buffer do
              ["}" | _] -> {:halt, %{acc | tokens: remaining, buffer: tl(buffer)}}
              _ -> {:cont, %{acc | tokens: remaining, buffer: [c | buffer]}}
            end

          _ ->
            {:cont, %{acc | tokens: remaining, buffer: [c | buffer]}}
        end
      end)

    case result.tokens do
      [] ->
        {:error, "Could not find closing symbols"} |> IO.inspect()

      _ ->
        scope = to_binary(result.buffer)
        closing_scope = %{interpolation: "/#{scope}"}

        {nodes, tokens} = process(result.tokens, [], [], closing_scope)

        {:ok, %{with_scope: scope, children: Enum.reverse(nodes), negative: result.negative},
         tokens}
    end
  end

  @doc "Parse an argument pair"
  @spec parse_argument([token], [parsed_node()]) :: {:ok, argument_pair(), remaining_tokens()}
  def parse_argument(tokens, _nodes) do
    init = %{
      key: [],
      key_done: false,
      value: [],
      tokens: tokens,
      opened: false,
      value_done: false
    }

    argument =
      Enum.reduce_while(tokens, init, fn c, acc ->
        next =
          cond do
            acc.value_done -> nil
            !acc.key_done && c != "=" -> %{acc | key: [c | acc.key]}
            !acc.key_done && c == "=" -> %{acc | key_done: true}
            acc.key_done && c == "'" && !acc.opened -> %{acc | opened: true}
            acc.opened && c != "'" -> %{acc | value: [c | acc.value]}
            acc.opened && c == "'" -> %{acc | value_done: true}
            true -> raise "Unknown state #{inspect(acc)}"
          end

        case next do
          nil ->
            {:halt, acc}

          _ ->
            next = Map.put(next, :tokens, tl(acc.tokens))
            {:cont, next}
        end
      end)

    {nodes, []} = process(Enum.reverse(argument.value), [], [], nil)
    {:ok, %{key: to_binary(argument.key), value: nodes}, argument.tokens}
  end

  @doc "Parse an interpolation node"
  @spec parse_interpolation([token], [parsed_node]) :: parse_result
  def parse_interpolation(tokens, _nodes) do
    init = %{done: false, buffer: [], tokens: tokens, error: ""}

    acc =
      Enum.reduce_while(tokens, init, fn c, acc ->
        case c do
          "^" ->
            {:halt, %{acc | done: false, tokens: tl(acc.tokens)}}

          "#" ->
            {:halt, %{acc | done: false, tokens: tl(acc.tokens)}}

          " " ->
            init = %{arguments: [], tokens: acc.tokens}

            %{arguments: arguments, tokens: tokens} =
              Enum.reduce_while(acc.tokens, init, fn _token, acc ->
                case match?(["}" | ["}" | _]], acc.tokens) do
                  true ->
                    {:halt, %{acc | tokens: acc.tokens |> tl |> tl}}

                  false ->
                    {:ok, node, tokens} = parse_argument(tl(acc.tokens), [])

                    {:cont, %{acc | arguments: [node | acc.arguments], tokens: tokens}}
                end
              end)

            {:halt,
             %{
               done: true,
               func: to_binary(acc.buffer),
               type: :function,
               arguments: arguments,
               tokens: tokens
             }}

          "}" ->
            case acc.buffer do
              ["}" | _] ->
                {:halt,
                 %{
                   done: true,
                   type: :interpolation,
                   buffer: tl(acc.buffer),
                   tokens: tl(acc.tokens)
                 }}

              _ ->
                {:cont, %{acc | buffer: [c | acc.buffer], tokens: tl(acc.tokens)}}
            end

          _ ->
            {:cont, %{acc | buffer: [c | acc.buffer], tokens: tl(acc.tokens)}}
        end
      end)

    case acc.done do
      false ->
        {:error, Map.get(acc, :error, "Are you missing }}?")}

      true ->
        case acc.type do
          :interpolation -> {:ok, %{interpolation: to_binary(acc.buffer)}, acc.tokens}
          :function -> {:ok, %{function: acc.func, arguments: acc.arguments}, acc.tokens}
        end
    end
  end

  defp process([], buffer, nodes, needle) do
    case needle do
      nil ->
        case buffer do
          [] ->
            {Enum.reverse(nodes), []}

          _ ->
            {Enum.reverse([%{plaintext: buffer |> Enum.reverse() |> Enum.join()} | nodes]), []}
        end

      _ ->
        raise "Was expecting #{inspect(needle)}"
    end
  end

  defp process(["{" | tokens], ["{" | buffer], nodes, needle) do
    case parse_node(tokens, nodes) do
      {:error, error} ->
        raise inspect(error)

      {:ok, node, tokens} ->
        case needle == node do
          true ->
            {[%{plaintext: to_binary(buffer)} | nodes], tokens}

          false ->
            case buffer do
              [] ->
                process(tokens, [], [node | nodes], needle)

              _ ->
                p = %{plaintext: to_binary(buffer)}
                process(tokens, [], [node, p] ++ nodes, needle)
            end
        end
    end
  end

  defp process([char | tokens], buffer, nodes, needle) do
    process(tokens, [char | buffer], nodes, needle)
  end

  defp maybe(rules, tokens, nodes) when is_list(rules) do
    result =
      rules
      |> Enum.map(&String.to_atom("parse_#{&1}"))
      |> Enum.reduce_while(nil, fn func, _ ->
        case Kernel.apply(__MODULE__, func, [tokens, nodes]) do
          {:error, _} -> {:cont, nil}
          {:ok, node, tokens} -> {:halt, {node, tokens}}
        end
      end)

    case result do
      nil -> {:error, "No match found"}
      {node, tokens} -> {:ok, node, tokens}
    end
  end

  defp to_binary(items) when is_list(items), do: items |> Enum.reverse() |> Enum.join()
end
