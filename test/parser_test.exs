defmodule Snor.ParserTest do
  use ExUnit.Case, async: true

  test "Parse", context do
    "Hello {{name}}"
    |> Snor.Parser.parse()
    |> IO.inspect(label: "op")

    assert 1 = 1
  end
end
