defmodule Snor.DataDrivenTest do
  use ExUnit.Case

  defp x(str, data \\ %{}) do
    Snor.render(str, data)
  end

  tests = [
    ["", ""],
    ["Hello World", "Hello World"],
    ["Hello World", %{}, "Hello World"],
    ["Hello {{", "Hello {{"],
    ["Hello }}", "Hello }}"],
    ["Hello {{}}", "Hello "],

    # Simple variable substitutions
    ["Hello {{name}}", "Hello "],
    ["Hello {{name}}", %{"name" => "John Doe"}, "Hello John Doe"],
    ["Hello {{name}}", %{"age" => "123"}, "Hello "],
    ["Hello {{age}}", %{"age" => 123}, "Hello 123"],
    ["Hello {{ {{age}}", %{"age" => 123}, "Hello {{ 123"],
    ["Hello {{ {{ {{age}}", %{"age" => 123}, "Hello {{ {{ 123"],
    ["{{f}}", %{"f" => "B", "l" => "C"}, "B"],
    ["{{", "{{"],
    ["}}", "}}"],
    ["{{}}", ""],
    ["{{{{}}}}", "{{}}"],
    ["{{hello}}", ""],
    ["{{f}} {{l}}", %{"f" => "B", "l" => "C"}, "B C"],

    # dot syntax for values
    ["{{person.name.first}}", %{person: %{name: %{first: "John Doe"}}}, "John Doe"],
    ["{{person.name}}", %{person: %{name: "John Doe"}}, "John Doe"],
    ["{{person.age}}", %{person: %{name: "John Doe"}}, ""],
    [
      "{{#person}}{{name.first}}{{/person}}",
      %{"person" => %{"name" => %{"first" => "John Doe"}}},
      "John Doe"
    ],

    # scoping
    ["{{#person}}{{name}}{{/person}}", %{"person" => %{"name" => "John Doe"}}, "John Doe"],

    # multiple scoped properties
    [
      "{{#person}}{{name}}, {{age}}{{/person}}",
      %{"person" => %{"name" => "John Doe", "age" => 123}},
      "John Doe, 123"
    ],

    # coming out of a scope
    [
      "{{#person}}{{name}}, {{age}}{{/person}} - {{city}}",
      %{"person" => %{"name" => "John Doe", "age" => 123}, "city" => "Amsterdam"},
      "John Doe, 123 - Amsterdam"
    ],

    # going into, and coming out of a scope
    [
      "{{country}}\n{{#person}}{{name}}, {{age}}{{/person}} - {{city}}",
      %{
        "person" => %{"name" => "John Doe", "age" => 123},
        "city" => "Amsterdam",
        "country" => "Netherlands"
      },
      "Netherlands\nJohn Doe, 123 - Amsterdam"
    ],

    # coming out of an invalid scope is an error
    [
      "{{#person}}{{name}}{{/dude}}",
      %{"person" => %{"name" => "John Doe"}},
      "John Doe",
      RuntimeError
    ],

    # coming out of an un-opened scope is an error
    [
      "{{name}}{{/dude}}",
      %{"name" => "John Doe"},
      "John Doe",
      RuntimeError
    ],

    # deeply nested scope
    [
      "{{#country}}{{#city}}{{#person}}{{name}}, {{age}}{{/person}}{{/city}}{{/country}}",
      %{"country" => %{"city" => %{"person" => %{"name" => "John Doe"}}}},
      "John Doe, "
    ],

    # scoping with dot syntax
    [
      "{{#person.name}}{{first}}{{/person.name}}",
      %{"person" => %{"name" => %{"first" => "John Doe"}}},
      "John Doe"
    ],

    # Skip missing nested property
    ["Hello {{#a}}b{{/a}} World!", %{}, "Hello  World!"],

    # deeply nested scope, prints nothing if key doesn't exist
    [
      "{{#country}}{{#city}}{{#person}}Details - {{name}}, {{age}}{{/person}}{{/city}}{{/country}}",
      %{},
      ""
    ],

    # Deeply nested, skips only the missing parts
    [
      "{{#country}}{{#city}}Details - {{name}}, {{age}}{{/city}} {{membership}}{{/country}}",
      %{"country" => %{"city" => %{"name" => "Amsterdam"}, "membership" => "Yes"}},
      "Details - Amsterdam,  Yes"
    ],

    # deeply nested scope, incorrect popping
    [
      "{{#country}}{{#city}}{{#person}}{{name}}, {{age}}{{/person}}{{/country}}{{/city}}",
      %{"country" => %{"city" => %{"person" => %{"name" => "John Doe"}}}},
      "John Doe, ",
      RuntimeError
    ],

    # deeply nested scope, non-existant
    [
      "{{#country}}{{#city}}{{#person}}{{name}}, {{age}}{{/person}}{{/country}}{{/city}}",
      %{},
      ", ",
      RuntimeError
    ],

    # multi parse?
    ["{{{{name}}}}", %{"name" => "John Doe"}, "{{John Doe}}"],

    # simple function to upcase some string
    ["{{upcase hello}}", "HELLO"],

    # function call with args
    ["{{upcase name}}", %{"name" => "John Doe"}, "JOHN DOE"],
    ["{{upcase name blah}}", %{"name" => "John Doe"}, "JOHN DOE", RuntimeError],

    # function call with nested-args
    ["{{upcase person.name}}", %{"person" => %{"name" => "John Doe"}}, "JOHN DOE"],

    # map style paramteres
    ["{{multiply a=5 b=10}}", "50"],

    # ------ DONE ----------
    ["All Done", "All Done"]
  ]

  tests
  |> Enum.with_index()
  |> Enum.each(fn {data, index} ->
    @name "Test ##{index}"

    case data do
      [input, output] ->
        @input input
        @output output

        test "#{@name}" do
          assert x(@input) == @output
        end

      [input, data, output] ->
        @input input
        @data data
        @output output

        test "#{@name}" do
          assert x(@input, @data) == @output
        end

      [input, data, output, error] ->
        @input input
        @data data
        @output output
        @error error

        test "#{@name}" do
          assert_raise(@error, fn -> x(@input, @data) end)
        end
    end
  end)
end
