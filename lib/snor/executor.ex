defmodule Snor.Executor do
  alias Snor.{Parser, Utils}

  @spec execute([Parser.template_node()], %{}, module()) :: String.t()
  def execute(tokens, data, helpers) do
    data = Utils.deep_stringify(data)

    tokens
    |> Enum.reverse()
    |> Enum.reduce(
      {%{data: data, scope: data, stack: [], branches: %{}}, []},
      &execute_node(helpers, &1, elem(&2, 0), elem(&2, 1))
    )
    |> elem(1)
    |> Enum.reverse()
    |> Enum.join()
  end

  # open negative scope ^
  #
  # When this happens, we re-push the current scope to the top of the stack
  # if the value lookup is absent.
  # If the value lookup is present, we push a skip scope to the stack
  #
  # The close scope operator takes case of the validations
  defp execute_node(_helpers, %{val: <<94, key::binary>>}, context, results) do
    %{scope: scope, stack: stack} = context

    target =
      case Utils.deep_get(scope, key, nil) do
        nil -> scope
        _ -> %{skip: true}
      end

    {%{context | scope: target, stack: [{key, scope} | stack]}, results}
  end

  # open scope #
  defp execute_node(_helpers, %{val: <<35, key::binary>>}, context, results) do
    %{scope: scope, stack: stack} = context
    target = Utils.deep_get(scope, key, %{skip: true}) || %{skip: true}

    case is_list(target) do
      false ->
        {%{context | scope: target, stack: [{key, scope} | stack]}, results}

      true ->
        result_map = Enum.reduce(target, %{}, fn index, acc -> Map.put(acc, index, []) end)

        {%{context | branches: result_map, scope: target, stack: [{key, scope} | stack]}, results}
    end
  end

  # close scope /
  defp execute_node(
         _helpers,
         %{val: <<47, key::binary>>},
         context = %{stack: [{name, scope} | stack]},
         results
       )
       when name == key do
    %{branches: branches} = context

    case Enum.empty?(branches) do
      true ->
        {%{context | scope: scope, stack: stack}, results}

      false ->
        all_branches = branches |> Map.values() |> Enum.reduce([], &(&2 ++ &1))
        {%{context | scope: scope, stack: stack, branches: %{}}, all_branches ++ results}
    end
  end

  # close scope /
  defp execute_node(_helpers, %{val: <<47, key::binary>>}, _, _results) do
    raise "Trying to close un-opened tag #{key}"
  end

  defp execute_node(_helpers, _, context = %{scope: %{skip: true}}, results),
    do: {context, results}

  defp execute_node(_helpers, %{type: :raw, val: val}, context, results) do
    %{branches: branches} = context

    case Enum.empty?(branches) do
      true ->
        {context, [val | results]}

      false ->
        branches =
          branches
          |> Enum.map(fn {scope, results} ->
            {scope, [val | results]}
          end)
          |> Enum.into(%{})

        {%{context | branches: branches}, results}
    end
  end

  defp execute_node(_helpers, %{type: :data, val: val}, context, results) do
    %{branches: branches} = context

    case Enum.empty?(branches) do
      true ->
        {context, [Utils.deep_get(context.scope, val, "") | results]}

      _ ->
        # wow, we are inside a loop construct
        # let's eagerly execute all the branches of the loop

        branches =
          branches
          |> Enum.map(fn {scope, results} ->
            {scope, [Utils.deep_get(scope, val, "") | results]}
          end)
          |> Enum.into(%{})

        {%{context | branches: branches}, results}
    end
  end

  defp execute_node(helpers, %{type: :fn, function: fn_name, args: args}, context, results) do
    %{branches: branches} = context

    case Enum.empty?(branches) do
      true ->
        {context,
         [
           Kernel.apply(helpers, fn_name, [context.data | args])
           | results
         ]}

      _ ->
        # wow, we are inside a loop construct
        # let's eagerly execute all the branches of the loop

        branches =
          branches
          |> Enum.map(fn {scope, results} ->
            {scope,
             [
               Kernel.apply(helpers, fn_name, [scope | args])
               | results
             ]}
          end)
          |> Enum.into(%{})

        {%{context | branches: branches}, results}
    end
  end
end
