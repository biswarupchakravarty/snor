defmodule Snor.EngineTest do
  use ExUnit.Case

  alias Snor
  doctest Snor
  doctest Snor.Parser

  test "plaintext" do
    assert Snor.process("Hello world") == "Hello world"
  end

  test "interpolation" do
    assert Snor.process("Hi, {{name}}", %{name: "John"}) == "Hi, John"
  end

  test "HTML escaping" do
    assert Snor.process("Hi, {{name}}", %{name: "& \" < >"}) == "Hi, &amp; &quot; &lt; &gt;"
  end

  test "blocks with dot syntax" do
    assert Snor.process("{{#person.name}}{{last}}, {{first}}{{/person.name}}", %{
             person: %{name: %{first: "John", last: "Doe"}}
           }) == "Doe, John"
  end

  test "implicit element" do
    assert Snor.process("{{#list}}({{.}}){{/list}}", %{list: [1, 2, "ADF", 5.4]}) ==
             "(1)(2)(ADF)(5.4)"
  end

  test "negative block empty list" do
    assert Snor.process("{{^list}}Yay lists!{{/list}}", %{list: []}) == "Yay lists!"
  end

  test "dotted block" do
    assert Snor.process("{{#list.items}}({{.}}){{/list.items}}", %{
             list: %{items: [1, 2, "ADF", 5.4]}
           }) == "(1)(2)(ADF)(5.4)"
  end

  require YamlElixir

  path = Path.join(File.cwd!(), "test/data/variables.yml")

  case YamlElixir.read_from_file(path) do
    {:error, error} ->
      raise error

    {:ok, test_cases} ->
      test_cases
      |> Enum.with_index()
      |> Enum.each(fn {test_case, index} ->
        @index index
        @error test_case["error"]
        @name test_case["name"] || ""
        @template test_case["template"]
        @expected_result test_case["result"]
        @data test_case["data"] || %{}

        case @error do
          nil ->
            test "[#{@index}] #{@name}" do
              actual_result = Snor.process(@template, @data)

              assert actual_result == @expected_result,
                     "Failed for ~#{@template}~, got ~#{actual_result}~, expected ~#{
                       @expected_result
                     }~"
            end

          _ ->
            test "[#{@index}] #{@name}" do
              assert_raise(String.to_atom("Elixir." <> @error), fn ->
                Snor.process(@template, @data)
              end)
            end
        end
      end)
  end
end
