defmodule Snor.Executor do
  @moduledoc """
  Module for executing a list of parsed nodes.
  """
  alias Snor.{Parser, Utils}

  @typedoc "The map provided to the template"
  @type data :: %{optional(any) => any}

  @doc "Convert a list of tokens into a string"
  @spec execute([Parser.parsed_node()], data, module()) :: String.t()
  def execute(tokens, data, helpers) do
    data = Utils.deep_stringify(data)

    tokens
    |> Enum.reduce(
      {%{data: data, scope: data, stack: [data], branches: %{}}, []},
      &execute(helpers, &1, elem(&2, 0), elem(&2, 1))
    )
    |> elem(1)
    |> Enum.reverse()
    |> Enum.join()
  end

  @spec deep_get(any, [binary]) :: any
  defp deep_get(data, []), do: data

  defp deep_get(data, [key | rest]) do
    case Map.get(data, key, nil) do
      nil -> ""
      x -> deep_get(x, rest)
    end
  end

  @spec maybe_escape(any, boolean) :: any
  defp maybe_escape(str, false),
    do: str

  defp maybe_escape(str, true) when is_binary(str), do: escape(str, [])
  defp maybe_escape(x, _), do: x

  defp escape(<<>>, chars),
    do: chars |> Enum.reverse() |> to_string

  defp escape(<<?&, rest::binary>>, chars),
    do: escape(rest, [?;, ?p, ?m, ?a, ?& | chars])

  defp escape(<<?", rest::binary>>, chars),
    do: escape(rest, [?;, ?t, ?o, ?u, ?q, ?& | chars])

  defp escape(<<?<, rest::binary>>, chars),
    do: escape(rest, [?;, ?t, ?l, ?& | chars])

  defp escape(<<?>, rest::binary>>, chars),
    do: escape(rest, [?;, ?t, ?g, ?& | chars])

  defp escape(<<c::utf8, rest::binary>>, chars),
    do: escape(rest, [c | chars])

  defp execute(_helpers, %{plaintext: plaintext}, context, results)
       when is_binary(plaintext),
       do: {context, [plaintext | results]}

  defp execute(_helpers, %{interpolation: key, escape: escape}, context, results) do
    case key do
      "." ->
        {context, [maybe_escape(context.scope, escape) | results]}

      _ ->
        segments = [segment | _] = String.split(key, ".")

        value =
          case Map.get(context.scope, segment, nil) do
            nil ->
              deep_get(context.data, segments)

            value when is_map(value) ->
              deep_get(value, tl(segments))

            value ->
              value
          end

        {context, [maybe_escape(value, escape) | results]}
    end
  end

  defp execute(helpers, %{function: fn_name, arguments: arguments}, context, results) do
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

  defp execute(helpers, node = %{with_scope: key}, context, results) do
    scope =
      case key do
        "." ->
          context.scope

        _ ->
          context.scope
          |> Utils.deep_get(key, Utils.deep_get(context.data, key, ""))
      end

    execute_block(helpers, node, scope, context, results)
  end

  defp execute(_helpers, _, context, results) do
    {context, results}
  end

  defp execute_block(
         helpers,
         %{negative: negative, children: children},
         scope,
         context,
         results
       )
       when is_map(scope) do
    # in a map context, negative means the map is empty
    blank_scope = map_size(scope) == 0

    if (negative and !blank_scope) or (!negative and blank_scope) do
      {context, results}
    else
      rendered_children =
        children
        |> Enum.reduce(
          {%{context | data: context.data, scope: scope}, []},
          &execute(helpers, &1, elem(&2, 0), elem(&2, 1))
        )
        |> elem(1)

      {context, rendered_children ++ results}
    end
  end

  defp execute_block(
         helpers,
         %{negative: negative, children: children},
         scope,
         context,
         results
       )
       when is_list(scope) do
    # in a list context, negative means that the list should be empty
    if negative and length(scope) > 0 do
      {context, results}
    else
      # else process all the things
      # if this is a negative scope, we need the loop to execute atleast
      # once, so shove an empty map in there
      rendered_children =
        if(negative, do: [%{}], else: scope)
        |> Enum.reverse()
        |> Enum.flat_map(fn scope ->
          children
          |> Enum.reduce(
            {%{context | data: context.data, scope: scope}, []},
            &execute(helpers, &1, elem(&2, 0), elem(&2, 1))
          )
          |> elem(1)
        end)

      {context, rendered_children ++ results}
    end
  end

  defp execute_block(
         helpers,
         %{negative: negative, children: children},
         scope,
         context,
         results
       ) do
    # in any context, negative means object is nil, or false
    blank_scope = is_nil(scope) or scope == false or scope == ""

    if (negative and !blank_scope) or (!negative and blank_scope) do
      {context, results}
    else
      rendered_children =
        children
        |> Enum.reduce(
          {%{context | data: context.data, scope: scope}, []},
          &execute(helpers, &1, elem(&2, 0), elem(&2, 1))
        )
        |> elem(1)

      {context, rendered_children ++ results}
    end
  end
end
