defmodule Snor.Executor do
  alias Snor.{Parser, Utils}

  @typedoc "The map provided to the template"
  @type data :: %{optional(any) => any}

  @doc "Convert a list of tokens into a string"
  @spec execute([Parser.parsed_node()], data, module()) :: String.t()
  def execute(tokens, data, helpers) do
    data = Utils.deep_stringify(data)

    tokens
    |> Enum.reduce(
      {%{data: data, scope: data, stack: [], branches: %{}}, []},
      &execute1(helpers, &1, elem(&2, 0), elem(&2, 1))
    )
    |> elem(1)
    |> Enum.reverse()
    |> Enum.join()
  end

  defp execute1(_helpers, %{plaintext: plaintext}, context, results)
       when is_binary(plaintext),
       do: {context, [plaintext | results]}

  defp execute1(_helpers, %{interpolation: key}, context, results) do
    with fallback <- Utils.deep_get(context.data, key, ""),
         value <- Utils.deep_get(context.scope, key, fallback),
         do: {context, [value | results]}
  end

  defp execute1(helpers, %{function: fn_name, arguments: arguments}, context, results) do
    arguments =
      arguments
      |> Enum.map(fn %{key: k, value: tokens} ->
        {k, execute(tokens, context.scope, helpers)}
      end)
      |> Enum.into(%{})

    {context,
     [
       Kernel.apply(helpers, String.to_atom(fn_name), [context.data, arguments])
       | results
     ]}
  end

  defp execute1(helpers, node = %{with_scope: key}, context, results) do
    children = node.children

    negative = Map.get(node, :negative, false)

    case Utils.deep_get(context.scope, key, Utils.deep_get(context.data, key, "")) do
      scope when is_list(scope) ->
        # in a list context, negative means that the list should be empty
        cond do
          negative and length(scope) > 0 ->
            {context, results}

          # else process all the things
          true ->
            # if this is a negative scope, we need the loop to execute atleast
            # once, so shove an empty map in there
            rendered_children =
              if(negative, do: [%{}], else: scope)
              |> Enum.reverse()
              |> Enum.flat_map(fn scope ->
                children
                |> Enum.reduce(
                  {%{context | data: context.data, scope: scope}, []},
                  &execute1(helpers, &1, elem(&2, 0), elem(&2, 1))
                )
                |> elem(1)
              end)

            {context, rendered_children ++ results}
        end

      scope when is_map(scope) ->
        # in a map context, negative means the map is empty
        blank_scope = map_size(scope) == 0

        cond do
          (negative and !blank_scope) or (!negative and blank_scope) ->
            {context, results}

          true ->
            rendered_children =
              children
              |> Enum.reduce(
                {%{context | data: context.data, scope: scope}, []},
                &execute1(helpers, &1, elem(&2, 0), elem(&2, 1))
              )
              |> elem(1)

            {context, rendered_children ++ results}
        end

      scope ->
        # in any context, negative means object is nil, or false
        blank_scope = is_nil(scope) or scope == false or scope == ""

        cond do
          (negative and !blank_scope) or (!negative and blank_scope) ->
            {context, results}

          true ->
            rendered_children =
              children
              |> Enum.reduce(
                {%{context | data: context.data, scope: scope}, []},
                &execute1(helpers, &1, elem(&2, 0), elem(&2, 1))
              )
              |> elem(1)

            {context, rendered_children ++ results}
        end
    end
  end

  defp execute1(_helpers, _, context, results) do
    {context, results}
  end
end
