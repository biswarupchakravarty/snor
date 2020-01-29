defmodule Snor.Parser do
  @moduledoc """
  Convert a string into an intermediate representation - a list of nodes.

  A node could be one of (mainly) -

  - A plaintext node
  - A function node
  - A block node
  - An interpolation node
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
  @type parse_result :: {:error, String.t()} | {:ok, parsed_node | any, binary()}

  @typedoc "A parser"
  @type parser :: function()

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
      [%{children: [%{interpolation: "name"}], negative: false, with_scope: "person"}]
  """
  @spec parse(binary()) :: [parsed_node()]
  def parse(input) do
    parser = nodes()

    case parser.(input) do
      {:ok, nodes, <<>>} -> nodes
      {:ok, _, _} -> raise ArgumentError, "Couldn't parse"
      {:error, error} -> raise ArgumentError, "Error #{error}"
    end
  end

  @spec nodes() :: parser()
  defp nodes,
    do:
      any_node()
      |> many()
      |> non_zero()

  @spec any_node() :: parser()
  defp any_node,
    do:
      [plaintext_node(), interpolation(), block(), function()]
      |> choice()
      |> non_zero()

  @spec plaintext_node() :: parser()
  defp plaintext_node do
    fn input ->
      with {:ok, contents, rest} <- plaintext().(input),
           <<_::utf8, _::binary>> <- contents do
        {:ok, %{plaintext: contents}, rest}
      else
        _ -> {:error, "Was expecting a plaintext node"}
      end
    end
  end

  @spec function() :: parser()
  defp function do
    fn input ->
      with {:ok, <<?{, ?{>>, rest} <- nchars(2).(input),
           {:ok, function_name, rest} <- plaintext_apart_from([?\s]).(rest),
           {:ok, arguments, rest} <- argument_pairs().(rest),
           {:ok, <<?}, ?}>>, rest} <- nchars(2).(rest) do
        {:ok, %{function: function_name, arguments: arguments}, rest}
      else
        _ -> {:error, "Expected function"}
      end
    end
  end

  @spec argument_pairs() :: parser()
  defp argument_pairs,
    do:
      argument_pair_with_leading_space()
      |> many
      |> non_zero()

  @spec argument_pair_with_leading_space() :: parser()
  defp argument_pair_with_leading_space do
    fn input ->
      with {:ok, ?\s, rest} <- char().(input),
           {:ok, pair, rest} <- argument_pair().(rest) do
        {:ok, pair, rest}
      else
        _ -> {:error, "Could not parse argument pair with leading space"}
      end
    end
  end

  @spec argument_pair() :: parser()
  defp argument_pair do
    fn input ->
      with {:ok, key, rest} <- plaintext_apart_from([?=]).(input),
           {:ok, ?=, rest} <- char().(rest),
           {:ok, value, rest} <- argument_value().(rest) do
        {:ok, %{key: key, value: value}, rest}
      else
        _ ->
          {:error, "Was expecting an argument pair"}
      end
    end
  end

  @spec argument_value() :: parser()
  defp argument_value do
    fn input ->
      with {:ok, ?', rest} <- char().(input),
           {:ok, contents, rest} <- argument_contents().(rest),
           {:ok, ?', rest} <- char().(rest),
           {:ok, inner_nodes, <<>>} <- nodes().(contents) do
        {:ok, inner_nodes, rest}
      else
        _ -> {:error, "Expected a quoted argument"}
      end
    end
  end

  @spec argument_contents() :: parser()
  defp argument_contents,
    do:
      char()
      |> satisfy(&(&1 != ?'), "anything but a '")
      |> many
      |> non_zero
      |> map(&to_string/1)

  @spec interpolation() :: parser()
  defp interpolation do
    fn input ->
      with {:ok, <<?{, ?{>>, rest} <- nchars(2).(input),
           {:ok, tag_name, rest} <- tag_name().(rest),
           {:ok, <<?}, ?}>>, rest} <- nchars(2).(rest) do
        {:ok, %{interpolation: tag_name}, rest}
      else
        _ ->
          {:error, "Expected an interpolation"}
      end
    end
  end

  @spec tag_name() :: parser()
  defp tag_name do
    char()
    |> satisfy(&(&1 in ?a..?z || &1 in ?A..?Z || &1 in ?0..?9 || &1 in [?_, ?.]))
    |> many()
    |> non_zero()
    |> map(&to_string/1)
  end

  @spec nodes_until(any) :: parser()
  defp nodes_until(needle),
    do:
      any_node()
      |> satisfy(&(&1 != needle), "anything but #{inspect(needle)}")
      |> many()
      |> non_zero()

  @spec block() :: parser()
  defp block do
    fn input ->
      with {:ok, %{opening_scope: scope, negative: negative}, rest} <- open_scope().(input),
           {:ok, contents, rest} <- nodes_until(%{closing_scope: scope}).(rest),
           {:ok, %{closing_scope: ^scope}, rest} <- close_scope().(rest) do
        {:ok, %{with_scope: scope, children: contents, negative: negative}, rest}
      else
        {:ok, %{closing_scope: scope}, _} ->
          {:error, "Closed #{scope}, but it was not opened"}

        _ ->
          {:error, "Was expecting a block"}
      end
    end
  end

  @spec open_scope() :: parser()
  defp open_scope do
    fn input ->
      with {:ok, <<?{, ?{>>, rest} <- nchars(2).(input),
           {:ok, tag_name, rest} <- plaintext().(rest),
           {:ok, <<?}, ?}>>, rest} <- nchars(2).(rest) do
        case tag_name do
          <<?#, tag::binary>> -> {:ok, %{opening_scope: tag, negative: false}, rest}
          <<?^, tag::binary>> -> {:ok, %{opening_scope: tag, negative: true}, rest}
          <<char::utf8, _::binary>> -> {:error, "A block cannot start with [#{char}]"}
        end
      else
        _ -> {:error, "Expected a block"}
      end
    end
  end

  @spec close_scope() :: parser()
  defp close_scope do
    fn input ->
      with {:ok, <<?{, ?{, ?/>>, rest} <- nchars(3).(input),
           {:ok, tag_name, rest} <- plaintext().(rest),
           {:ok, <<?}, ?}>>, rest} <- nchars(2).(rest) do
        {:ok, %{closing_scope: tag_name}, rest}
      else
        _ -> {:error, "Expected a block close"}
      end
    end
  end

  @spec map(parser(), fun()) :: parser()
  defp map(parser, mapper) do
    fn input ->
      with {:ok, term, rest} <- parser.(input),
           do: {:ok, mapper.(term), rest}
    end
  end

  @spec plaintext() :: parser()
  defp plaintext,
    do:
      plaintext_chars()
      |> map(&to_string/1)

  @spec plaintext_apart_from([byte()]) :: parser()
  defp plaintext_apart_from(chars),
    do:
      plaintext_char()
      |> satisfy(&(&1 not in chars), "anything but #{chars}")
      |> many()
      |> non_zero()
      |> map(&to_string/1)

  @spec non_zero(parser()) :: parser()
  defp non_zero(parser) do
    fn input ->
      with {:ok, [], _rest} <- parser.(input),
           do: {:error, "Wasn't expecting nothing"}
    end
  end

  @spec choice([parser()]) :: parser()
  defp choice(parsers) do
    fn input ->
      case parsers do
        [] ->
          {:error, "No way to parse - #{input}"}

        [h | t] ->
          with {:error, _} <- h.(input),
               do: choice(t).(input)
      end
    end
  end

  @spec many(parser()) :: parser()
  defp many(parser) do
    fn input ->
      case parser.(input) do
        {:error, _error} ->
          {:ok, [], input}

        {:ok, term, rest} ->
          with {:ok, other_terms, rest} <- many(parser).(rest),
               do: {:ok, [term | other_terms], rest}
      end
    end
  end

  @spec satisfy(parser(), fun(), String.t()) :: parser()
  defp satisfy(parser, predicate, expectation \\ "unexpected input") do
    fn input ->
      with {:ok, term, rest} <- parser.(input) do
        if predicate.(term),
          do: {:ok, term, rest},
          else: {:error, "Expected #{expectation} before #{rest}"}
      end
    end
  end

  @spec consume_plaintext(binary, [byte], binary) :: {:ok, [byte], binary}
  defp consume_plaintext(<<>>, buf, rest), do: {:ok, Enum.reverse(buf), rest}

  defp consume_plaintext(<<?}::utf8, ?}::utf8, _::binary>>, buf, rest),
    do: {:ok, Enum.reverse(buf), rest}

  defp consume_plaintext(<<?{::utf8, ?{::utf8, _::binary>>, buf, rest),
    do: {:ok, Enum.reverse(buf), rest}

  defp consume_plaintext(<<char::utf8, rest::binary>>, buf, _),
    do: consume_plaintext(rest, [char | buf], rest)

  @spec plaintext_chars() :: parser()
  defp plaintext_chars,
    do: &consume_plaintext(&1, [], &1)

  @spec plaintext_char() :: parser()
  defp plaintext_char do
    fn input ->
      case input do
        <<>> ->
          {:error, "Unexpected end of input"}

        <<?}::utf8, ?}::utf8, _::binary>> ->
          {:error, "reached closing braces"}

        <<?{::utf8, ?{::utf8, _::binary>> ->
          {:error, "reached opening braces"}

        <<char::utf8, rest::binary>> ->
          {:ok, char, rest}
      end
    end
  end

  @spec char() :: parser()
  defp char do
    fn input ->
      case input do
        "" -> {:error, "Unexpected end of input"}
        <<char::utf8, rest::binary>> -> {:ok, char, rest}
      end
    end
  end

  @spec nchars(non_neg_integer()) :: parser()
  defp nchars(n) do
    fn input ->
      case input do
        <<chars::binary-size(n), rest::binary>> -> {:ok, chars, rest}
        _ -> {:error, "Unexpected end of input"}
      end
    end
  end
end
