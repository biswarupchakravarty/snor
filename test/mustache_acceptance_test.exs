defmodule Snor.MustacheAcceptanceTest do
  use ExUnit.Case, async: false
  require YamlElixir

  to_exclude = [
    "[sections.yml] Deeply Nested Contexts",
    "[inverted.yml] Doubled",
    "[sections.yml] Padding",
    "[sections.yml] Doubled",
  ]

  path = Path.join(File.cwd!(), "test/mustache_spec/specs")

  path
  |> File.ls!()
  |> Enum.filter(&(!String.ends_with?(&1, ".json") && !String.starts_with?(&1, "~")))
  |> Enum.filter(&(&1 not in ~w(partials.yml delimiters.yml)))
  |> Enum.each(fn file ->
    %{"tests" => tests} = YamlElixir.read_from_file!(Path.join(path, file))

    Enum.each(tests, fn test_case ->
      @name test_case["name"] || ""
      @template test_case["template"]
      @expected_result test_case["expected"]
      @data test_case["data"] || %{}
      @name "[#{file}] #{test_case["name"]}"
      is_pending =
        String.contains?(@name, "Standalone")
      || Enum.any?(to_exclude, & String.contains?(@name, &1))
      @tag_type if is_pending,
        do: :pending, else: :acceptance
      @tag @tag_type
      test @name do
        actual_result = Snor.render(@template, @data)

        assert actual_result == @expected_result
      end
    end)
  end)
end
