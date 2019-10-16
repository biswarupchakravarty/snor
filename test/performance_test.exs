defmodule Snor.PerformanceTest do
  use ExUnit.Case, async: true

  defp x(str) do
    Snor.Parser.parse(str)
  end

  setup do
    repeater = "Hello {{name}}, meet {{another}}!
    {{#nested}}{{value}}{{/nested}} \n
    {{ is allowed {{upcase YO}}."

    str = 1..200 |> Enum.map(fn _ -> repeater end) |> Enum.join("")
    num_bytes = byte_size(str)
    %{str: str, num_bytes: num_bytes, times: 100}
  end

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

    IO.puts(
      "\n[PARSE] Took #{time_ms}ms total, average #{avg_time}ms per, #{context[:num_bytes]} bytes"
    )

    assert avg_time < 5
  end

  test "Executing a large parse tree", context do
    parse_tree = Snor.Parser.parse(context.str)
    num_nodes = length(parse_tree)

    data = %{"name" => "Biswarup", "another" => "", "nested" => %{"value" => ""}}

    num_bytes = byte_size(Snor.Executor.execute(parse_tree, data, Snor.Helpers))

    total_time =
      1..context[:times]
      |> Enum.map(fn _index ->
        {time, _} = :timer.tc(fn -> Snor.Executor.execute(parse_tree, data, Snor.Helpers) end)

        time
      end)
      |> Enum.sum()

    time_ms = total_time / 1_000
    avg_time = time_ms / context[:times]

    IO.puts(
      "\n[EXECUTE] Took #{time_ms}ms total, average #{avg_time}ms per, #{num_nodes} nodes, #{
        num_bytes
      } bytes in output"
    )

    assert avg_time < 5
  end
end
