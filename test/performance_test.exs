defmodule Snor.PerformanceTest do
  require Logger
  use ExUnit.Case

  defp x(str) do
    Snor.Parser.parse(str)
  end

  setup do
    repeater = "Hello {{name}}, meet {{another}}!
    {{#nested}}{{value}}{{/nested}} \n
     is allowed {{#a}} {{upcase item='YO'}} {{upcase item='{{name}}'}} {{/a}}."

    str = 1..100 |> Enum.map(fn _ -> repeater end) |> Enum.join("")
    num_bytes = byte_size(str)
    %{str: str, num_bytes: num_bytes, times: 50}
  end

  @tag :pending
  test "Parsing a large string", context do
    total_time =
      1..context[:times]
      |> Enum.map(fn _index ->
        {time, _} = :timer.tc(fn -> x(context.str) end)
        time
      end)
      |> Enum.sum()

    time_ms = total_time / 1_000
    avg_time = time_ms / context[:times]

    Logger.debug(
      "\n[PARSE] Took #{time_ms}ms total, average #{avg_time}ms per, #{context[:num_bytes]} bytes"
    )

    assert avg_time < 50
  end

  @tag :pending
  test "Executing a large parse tree", context do
    parse_tree = Snor.NewParser.parse(context.str)
    num_nodes = length(parse_tree)

    data = %{"name" => "Biswarup", "another" => "", "nested" => %{"value" => ""}}

    num_bytes = byte_size(Snor.NewExecutor.execute(parse_tree, data, Snor.Helpers))

    total_time =
      1..context[:times]
      |> Enum.map(fn _index ->
        {time, _} = :timer.tc(fn -> Snor.NewExecutor.execute(parse_tree, data, Snor.Helpers) end)

        time
      end)
      |> Enum.sum()

    time_ms = total_time / 1_000
    avg_time = time_ms / context[:times]

    Logger.debug(
      "\n[EXECUTE] Took #{time_ms}ms total, average #{avg_time}ms per, #{num_nodes} nodes, #{
        num_bytes
      } bytes in output"
    )

    assert avg_time < 50
  end
end
