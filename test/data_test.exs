defmodule Snor.DataTest do
  use ExUnit.Case
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
              actual_result = Snor.NewParser.render(@template, @data)
              assert actual_result == @expected_result
            end

          # test "[COMPILE] [#{@index}] #{@name}" do
          #    src =
          #        @template
          #        |> Snor.Parser.parse()
          #        |> Snor.Compiler.compile()

          #      compiled_src = Code.string_to_quoted!(src)
          #      module_name = String.to_atom("CTemplate.#{@index}")
          #      Module.create(module_name, compiled_src, Macro.Env.location(__ENV__))

          #      actual_result = module_name.execute(@data)
          #      assert actual_result == @expected_result
          #    end

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
