defmodule Snor.Parser do
  defp make_token(plaintext) when is_binary(plaintext), do: %{plaintext: plaintext}

  defp make_token({:interpolation, key}) do
    %{interpolation: String.split(key, "."), raw: false}
  end

  defp make_token({:interpolation_raw, key}) do
    %{interpolation: String.split(key, "."), raw: true}
  end

  # defp make_token({:plaintext, contents}), do: %{plaintext: contents}

  defp make_token({:block, [[type, name] | tokens]}) do
    [^name | tokens] = Enum.reverse(tokens)

    if type in ~w(# ^) do
      %{block: name, negative: type == "^", tokens: Enum.reverse(tokens)}
    else
      raise "Unsupported block type"
    end
  end

  defp make_token({:function, data}) do
    case data do
      [name] ->
        %{function: name}

      [name | arguments] ->
        Enum.reduce(arguments, &Map.merge/2)
        |> Map.put(:function, name)
    end
  end

  defp make_token({:argument, [key, value]}) do
    with {:ok, tokens, "", %{}, _, _} <- parse_binary(value) do
      %{key => tokens}
    end
  end

  defp check(<<?{, ?{, _::binary>>, c, _, _), do: {:halt, c}
  defp check(<<?{, _::binary>>, c, _, _), do: {:halt, c}
  defp check(_, c, _, _), do: {:cont, c}

  # parsec:Snor.Parser
  import NimbleParsec

  open_brackets = string("{{")
  open_brackets_raw = string("{{{")
  close_brackets = string("}}")
  close_brackets_raw = string("}}}")

  plaintext =
    ascii_string([not: ?{], min: 1)
    |> map({:make_token, []})

  whitespace = ascii_string([?\s], min: 0)

  valid_identifier = ascii_string([?a..?z, ?A..?Z, ?0..?9, ?_, ?.], min: 1)

  identifier_with_whitespace =
    ignore(whitespace)
    |> concat(valid_identifier)
    |> ignore(whitespace)

  basic_interpolation =
    ignore(open_brackets)
    |> concat(identifier_with_whitespace)
    |> ignore(close_brackets)
    |> unwrap_and_tag(:interpolation)
    |> map({:make_token, []})

  ampersand_interpolation =
    ignore(open_brackets)
    |> concat(ignore(optional(string("&"))))
    |> concat(identifier_with_whitespace)
    |> ignore(close_brackets)
    |> unwrap_and_tag(:interpolation_raw)
    |> map({:make_token, []})

  triple_mustache_interpolation =
    ignore(open_brackets_raw)
    |> concat(identifier_with_whitespace)
    |> ignore(close_brackets_raw)
    |> unwrap_and_tag(:interpolation_raw)
    |> map({:make_token, []})

  interpolation_current_element =
    ignore(open_brackets)
    |> ignore(whitespace)
    |> ascii_char([?.])
    |> ignore(whitespace)
    |> replace(:current_element)
    |> ignore(close_brackets)

  interpolation =
    choice([
      interpolation_current_element,
      basic_interpolation,
      triple_mustache_interpolation,
      ampersand_interpolation
    ])

  comment =
    string("{{!")
    |> eventually(string("}}"))
    |> replace(:comment)

  close_block =
    ignore(open_brackets)
    |> ignore(string("/"))
    |> concat(identifier_with_whitespace)
    |> ignore(close_brackets)

  open_block =
    ignore(open_brackets)
    |> choice([string("#"), string("^")])
    |> concat(identifier_with_whitespace)
    |> ignore(close_brackets)
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
