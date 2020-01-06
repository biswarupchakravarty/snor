defmodule Snor.DataTest do
  use ExUnit.Case, async: false
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
              actual_result = Snor.render(@template, @data)

              assert actual_result == @expected_result,
                     "Failed for ~#{@template}~, got ~#{actual_result}~"
            end

          _ ->
            test "[#{@index}] #{@name}" do
              assert_raise(String.to_atom("Elixir." <> @error), fn ->
                Snor.render(@template, @data)
              end)
            end
        end
      end)
  end
end
