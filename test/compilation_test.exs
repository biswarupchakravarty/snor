defmodule Snor.CompilationTest do
  use ExUnit.Case, async: true

  setup do
    repeater = "
    Hello, {{name}} Welcome to {{city}}.
    {{#friend}}{{name}}{{/friend}} == {{friend.name}}
    {{upcase YO}}"

    str = 1..1 |> Enum.map(fn _ -> repeater end) |> Enum.join("")
    num_bytes = byte_size(str)

    %{
      str: str,
      times: 1,
      num_bytes: num_bytes,
      args: %{name: "Biswarup", city: "Amsterdam", friend: %{name: "Dude"}}
    }
  end

  test "Executing a compiled string", context do
    src =
      context[:str]
      |> Snor.Parser.parse()
      |> Snor.Compiler.compile()

    {compile_time, _} =
      :timer.tc(fn ->
        IO.puts("Compiling #{context[:num_bytes]} bytes")
        compiled_src = Code.string_to_quoted!(src)
        Module.create(CTemplate, compiled_src, Macro.Env.location(__ENV__))
      end)

    IO.puts("Compiled in #{compile_time / 1_000}ms, sleeping before running")
    IO.puts("Output size is #{byte_size(CTemplate.execute(context.args))} bytes")
    :timer.sleep(1_000)

    total_time =
      1..context[:times]
      |> Enum.map(fn _index ->
        {time, _} = :timer.tc(fn -> CTemplate.execute(context.args) end)
        time
      end)
      |> Enum.sum()

    time_ms = total_time / 1_000
    avg_time = time_ms / context[:times]
    IO.puts("\n[COMPILED] Took #{time_ms}ms total, average #{avg_time}ms per")
  end

  test "Executing uncompiled string", context do
    parse_tree = Snor.Parser.parse(context.str)
    num_nodes = length(parse_tree)

    num_bytes = byte_size(Snor.Executor.execute(parse_tree, context.args, Snor.Helpers))

    total_time =
      1..context[:times]
      |> Enum.map(fn _index ->
        {time, _} =
          :timer.tc(fn ->
            Snor.Executor.execute(parse_tree, context.args, Snor.Helpers)
          end)

        time
      end)
      |> Enum.sum()

    time_ms = total_time / 1_000
    avg_time = time_ms / context[:times]

    IO.puts(
      "\n[UNCOMPILED] Took #{time_ms}ms total, average #{avg_time}ms per, #{num_nodes} nodes, #{
        num_bytes
      } bytes in output"
    )

    assert avg_time < 5
  end
end
