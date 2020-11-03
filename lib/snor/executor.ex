defmodule Snor.Executor do
  def execute(tokens, data, _helpers \\ nil)

  def execute(tokens, data, helpers) when is_list(data) do
    case data do
      [] ->
        ""

      _ ->
        data
        |> Enum.map(&execute(tokens, &1, helpers))
        |> Enum.join("")
    end
  end

  def execute(tokens, data, _helpers) when is_map(data) do
    tokens
    |> Enum.map(&execute_token(&1, {data}))
    |> Enum.join()
  end

  def execute(tokens, data, _helpers) do
    tokens
    |> Enum.map(&execute_token(&1, {%{__current_element__: data}}))
    |> Enum.join()
  end

  defp escape_html(input, _) when not is_binary(input), do: input
  defp escape_html(<<>>, chars), do: chars |> Enum.reverse() |> :binary.list_to_bin()
  defp escape_html(<<?&::size(8), rest::binary>>, chars), do: escape_html(rest, ["&amp;" | chars])
  defp escape_html(<<?<::size(8), rest::binary>>, chars), do: escape_html(rest, ["&lt;" | chars])
  defp escape_html(<<?>::size(8), rest::binary>>, chars), do: escape_html(rest, ["&gt;" | chars])

  defp escape_html(<<?"::size(8), rest::binary>>, chars),
    do: escape_html(rest, ["&quot;" | chars])

  defp escape_html(<<x::size(8), rest::binary>>, chars), do: escape_html(rest, [x | chars])

  defp execute_token(%{interpolation: path, raw: raw}, {data}) do
    result = get_in(data, path)
    if raw, do: result, else: escape_html(result, [])
  end

  defp execute_token(:current_element, {%{__current_element__: data}}), do: "#{data}"

  defp execute_token(%{plaintext: plaintext}, _), do: plaintext

  defp execute_token(:comment, _), do: ''

  defp execute_token(%{block: name, negative: negative, tokens: tokens}, {data}) do
    value = get_in(data, String.split(name, "."))

    execute? =
      (negative && empty?(value)) ||
        (!negative && !empty?(value))

    value = if execute? && value == [], do: [""], else: value

    if execute?, do: execute(tokens, value), else: ""
  end

  defmodule Helpers do
    def upcase(s), do: String.upcase(s)

    def multiply(a, b) do
      {a, _} = Integer.parse(a)
      {b, _} = Integer.parse(b)
      a * b
    end
  end

  defp execute_token(f = %{function: "upcase"}, {data}) do
    Helpers.upcase(execute(f["item"], data))
  end

  defp execute_token(f = %{function: "multiply"}, {data}) do
    Helpers.multiply(execute(f["a"], data), execute(f["b"], data))
  end

  @spec empty?(any) :: boolean
  defp empty?(value) do
    case value do
      x when is_nil(x) or x == [] or x == %{} or x == <<>> or x == false -> true
      _ -> false
    end
  end
end
