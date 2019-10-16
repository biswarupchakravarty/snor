defmodule Snor.Compiler do
  @moduledoc """
  THIS IS EXPERIMENTAL, AND MOSTLY FOR ME TO PLAY AROUND WITH.
  DO NOT USE
  """
  alias Snor.Parser

  @doc """
  Experimental
  """
  @spec compile([Parser.template_node()]) :: any()
  def compile(parsed_tree) do
    contents =
      parsed_tree
      |> Enum.reverse()
      |> Enum.reduce(
        {[], []},
        &compile_node(&1, elem(&2, 0), elem(&2, 1))
      )
      |> elem(1)
      |> Enum.reverse()

    "def execute(data) do
      data = Snor.Utils.deep_stringify(data)
      #{contents |> Enum.join(" <> ")}
    end"
  end

  # open scope #
  defp compile_node(%{val: <<35, key::binary>>}, path, contents),
    do: {x(key) ++ path, contents}

  # close scope /
  defp compile_node(%{val: <<47, key::binary>>}, [name | tail], contents) when name == key,
    do: {tail, contents}

  # close scope /
  defp compile_node(%{val: <<47, key::binary>>}, path, contents),
    do: {path, ["IO.warn(\"Trying to close un-opened tag #{key})\"" | contents]}

  # defp compile_node(_, context = %{scope: %{skip: true}}, results),
  #   do: {context, results}

  defp compile_node(%{type: :raw, val: val}, path, contents),
    do: {path, ["\"#{val}\"" | contents]}

  defp compile_node(%{type: :data, val: val}, path, contents),
    do: {path, ["(get_in(data, #{inspect(path ++ x(val))}) || <<>>)" | contents]}

  defp compile_node(%{type: :fn, function: fn_name, args: args}, path, contents),
    do: {path, ["Snor.Helpers.#{fn_name}(data, \"#{Enum.join(args, "\", \"")}\")" | contents]}

  defp x(maybe_dotted_path), do: String.split(maybe_dotted_path, ".", trim: true)
end
