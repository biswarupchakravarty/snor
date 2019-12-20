defmodule Snor.NewParser do
  def render(template, data) do
    render(template, data, nil)
  end

  def render(template, data, helpers) do
    parse(template)
    |> execute(data, helpers)
  end

  @doc """
  Parse a template into a list of tokens
  """
  @spec parse(binary()) :: list()
  def parse(template) do
    {:ok, tokens, _} = template |> to_charlist |> :template_lexer.string()

    {:ok, nodes} = tokens |> :template_parser.parse()
    nodes
  end

  def execute(nodes, data, _helpers) do
    context = %{stack: [data], results: [], helpers: Snor.Helpers}

    Enum.reduce(
      nodes,
      context,
      fn x, c -> execute_node(x, c) end
    )
    |> Map.get(:results)
    |> Enum.reverse()
    |> Enum.join("")
  end

  def test() do
    parse("{{upcase(item=\"name\")}}")
    |> execute(
      %{
        "pets" => [
          %{"breed" => "rabid"},
          %{"breed" => "cat"}
        ]
      },
      nil
    )
  end

  def execute_node(string, context) when is_binary(string) do
    %{
      context
      | results: [string | context.results]
    }
  end

  def execute_node({:with_scope, key, children}, context) do
    value =
      key
      |> to_string
      |> String.replace("{{#", "")
      |> String.replace("}}", "")
      |> String.split(".")

    case get_in(hd(context.stack), value) do
      nil ->
        %{
          context
          | results: ["" | context.results]
        }

      items when is_list(items) ->
        unrolled =
          items
          |> Enum.reverse()
          |> Enum.map(fn item ->
            new_context = %{
              results: [],
              stack: [item | context.stack]
            }

            children
            |> Enum.reduce(new_context, fn x, c ->
              execute_node(x, c)
            end)
            |> Map.get(:results)
            |> Enum.reverse()
          end)

        %{context | results: context.results ++ unrolled}

      new_scope when is_map(new_scope) ->
        new_context = %{
          results: [],
          stack: [new_scope | context.stack]
        }

        inner_results =
          children
          |> Enum.reduce(new_context, fn x, c -> execute_node(x, c) end)

        %{
          context
          | results: inner_results.results ++ context.results
        }
    end
  end

  def execute_node({:interpolate, key}, context) do
    value =
      key
      |> to_string
      |> String.replace("{{", "")
      |> String.replace("}}", "")
      |> String.split(".")

    %{
      context
      | results: [get_in(hd(context.stack), value) | context.results]
    }
  end

  def execute_node({:function, contents}, context) do
    stripped =
      contents
      |> to_string
      |> String.replace("{{", "")
      |> String.replace("}}", "")
      |> String.to_charlist()
      |> Enum.reverse()
      |> tl
      |> Enum.reverse()
      |> to_string

    [fn_name, others] = stripped |> String.split("(")

    arguments =
      others
      |> String.split(" ")
      |> Enum.reduce(%{}, fn pair, args ->
        [key, value] = String.split(pair, "=")

        value =
          value
          |> String.to_charlist()
          |> tl()
          |> Enum.reverse()
          |> tl()
          |> Enum.reverse()
          |> to_string

        Map.merge(args, %{key => value})
      end)

    %{
      context
      | results: [
          Kernel.apply(context.helpers, String.to_atom(fn_name), [hd(context.stack), arguments])
          | context.results
        ]
    }
  end
end
