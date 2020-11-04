defmodule Snor.Parser do
  defp make_token(plaintext) when is_binary(plaintext), do: %{plaintext: plaintext}

  defp make_token({:interpolation, key}) do
    %{interpolation: String.split(key, "."), raw: false}
  end

  defp make_token({:interpolation_raw, key}) do
    %{interpolation: String.split(key, "."), raw: true}
  end

  defp make_token({:block, [[type, name] | tokens]}) do
    [^name | tokens] = Enum.reverse(tokens)
    %{block: name, negative: is_negative?(type), tokens: Enum.reverse(tokens)}
  end

  defp make_token({:function, [name | arguments]}) do
    arguments
    |> Enum.reduce(&Map.merge/2)
    |> Map.put(:function, name)
  end

  defp make_token({:argument, [key, value]}) do
    with {:ok, tokens, "", %{}, _, _} <- parse_binary(value) do
      %{key => tokens}
    end
  end

  defp make_token(:current_element), do: :current_element

  defp is_negative?(?^), do: true
  defp is_negative?(?#), do: false

  # parsec:Snor.Parser
  import NimbleParsec

  open_brackets = string("{{")
  close_brackets = string("}}")

  plaintext =
    ascii_string([not: ?{], min: 1)
    |> map({:make_token, []})

  whitespace = ascii_string([?\s], min: 1)

  valid_identifier = ascii_string([?a..?z, ?A..?Z, ?0..?9, ?_, ?.], min: 1)

  make_tag = fn open_tag, close_tag, contents ->
    open_tag
    |> ignore(optional(whitespace))
    |> concat(contents)
    |> ignore(optional(whitespace))
    |> concat(close_tag)
  end

  make_interpolation = fn open_tag, close_tag, contents ->
    make_tag.(ignore(string(open_tag)), ignore(string(close_tag)), contents)
  end

  interpolation =
    choice([
      make_interpolation.("{{", "}}", ignore(string("."))) |> replace(:current_element),
      make_interpolation.("{{", "}}", valid_identifier) |> unwrap_and_tag(:interpolation),
      make_interpolation.("{{{", "}}}", valid_identifier) |> unwrap_and_tag(:interpolation_raw),
      make_interpolation.("{{&", "}}", valid_identifier) |> unwrap_and_tag(:interpolation_raw)
    ])
    |> map({:make_token, []})

  comment =
    string("{{!")
    |> eventually(string("}}"))
    |> replace(:comment)

  close_block = make_tag.(ignore(string("{{/")), ignore(string("}}")), valid_identifier)

  open_block =
    make_tag.(
      ignore(string("{{")) |> ascii_char([?#, ?^]),
      ignore(string("}}")),
      valid_identifier
    )
    |> wrap

  block =
    open_block
    |> concat(lookahead_not(string("{{/")) |> parsec(:parse_binary))
    |> concat(close_block)
    |> tag(:block)
    |> map({:make_token, []})

  argument_pair =
    lookahead_not(string("='"))
    |> concat(valid_identifier)
    |> ignore(string("='"))
    |> ascii_string([not: ?'], min: 1)
    |> tag(:argument)
    |> ignore(string("'"))
    |> ignore(optional(string(" ")))
    |> map({:make_token, []})

  function_start =
    ignore(open_brackets)
    |> concat(valid_identifier)
    |> ignore(string(" "))

  invocation =
    function_start
    |> times(argument_pair, min: 1)
    |> ignore(close_brackets)
    |> tag(:function)
    |> map({:make_token, []})

  defparsec(
    :parse_binary,
    choice([invocation, block, interpolation, plaintext, comment])
    |> times(min: 1)
  )

  # parsec:Snor.Parser
end
