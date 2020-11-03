defmodule Snor.BencheeTest do
  use ExUnit.Case, async: false

  alias Snor.Parser

  setup do
    repeater = "Hello {{name}}, meet {{another}}!
    {{#nested}}{{value}}{{/nested}} \n
     is allowed {{#a}} {{upcase item='YO'}} {{upcase item='{{name}}'}} {{/a}}."

    payloads =
      %{
        mostly_tags: repeater,
        plaintext: "Hello World This Is Text.\n",
        interpolation: "{{hello}}{{&hello}}{{{hello}}}"
      }
      |> Enum.map(fn {k, v} -> {k, Enum.join(Enum.map(1..100, fn _ -> v end))} end)
      |> Enum.into(%{})

    {:ok, payloads: payloads}
  end

  @tag :pending
  test "parsing", context do
    context.payloads
    |> Enum.map(fn {test, contents} ->
      {test, fn -> Parser.parse_binary(contents) end}
    end)
    |> Enum.into(%{})
    |> Benchee.run(time: 6, memory_time: 2)
  end
end
