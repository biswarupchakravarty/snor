defmodule Snor.Executor do
  alias Snor.{Parser, Utils}

  @spec execute([Parser.template_node()], %{}, module()) :: String.t()
  def execute(tokens, data, helpers) do
    data = Utils.deep_stringify(data)

    tokens
    |> Enum.reverse()
    |> Enum.reduce(
      {%{data: data, scope: data, stack: []}, []},
      &execute_node(helpers, &1, elem(&2, 0), elem(&2, 1))
    )
    |> elem(1)
    |> Enum.reverse()
    |> Enum.join()
  end

  # open scope #
  defp execute_node(_helpers, %{val: <<35, key::binary>>}, context, results) do
    %{scope: scope, stack: stack} = context
    target = Utils.deep_get(scope, key, %{skip: true}) || %{skip: true}

    {%{context | scope: target, stack: [{key, scope} | stack]}, results}
  end

  # close scope /
  defp execute_node(
         _helpers,
         %{val: <<47, key::binary>>},
         context = %{stack: [{name, scope} | stack]},
         results
       )
       when name == key do
    {%{context | scope: scope, stack: stack}, results}
  end

  # close scope /
  defp execute_node(_helpers, %{val: <<47, key::binary>>}, _, _results) do
    raise "Trying to close un-opened tag #{key}"
  end

  defp execute_node(_helpers, _, context = %{scope: %{skip: true}}, results),
    do: {context, results}

  defp execute_node(_helpers, %{type: :raw, val: val}, context, results) do
    {context, [val | results]}
  end

  defp execute_node(_helpers, %{type: :data, val: val}, context, results) do
    {context, [Utils.deep_get(context.scope, val, "") | results]}
  end

  defp execute_node(helpers, %{type: :fn, function: fn_name, args: args}, context, results) do
    {context,
     [
       Kernel.apply(helpers, fn_name, [context.data | args])
       | results
     ]}
  end
end
