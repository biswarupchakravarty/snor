# Generated from lib/snor/parser.ex.exs, do not edit.
# Generated at 2020-11-05 09:21:21Z.

defmodule Snor.Parser do
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

  defp make_token(plaintexts) when is_list(plaintexts),
    do: %{plaintext: List.to_string(plaintexts)}

  defp is_negative?(?^), do: true
  defp is_negative?(?#), do: false

  @doc """
  Parses the given `binary` as parse_binary.

  Returns `{:ok, [token], rest, context, position, byte_offset}` or
  `{:error, reason, rest, context, line, byte_offset}` where `position`
  describes the location of the parse_binary (start position) as `{line, column_on_line}`.

  ## Options

    * `:byte_offset` - the byte offset for the whole binary, defaults to 0
    * `:line` - the line and the byte offset into that line, defaults to `{1, byte_offset}`
    * `:context` - the initial context value. It will be converted to a map

  """
  @spec parse_binary(binary, keyword) ::
          {:ok, [term], rest, context, line, byte_offset}
          | {:error, reason, rest, context, line, byte_offset}
        when line: {pos_integer, byte_offset},
             byte_offset: pos_integer,
             rest: binary,
             reason: String.t(),
             context: map()
  def parse_binary(binary, opts \\ []) when is_binary(binary) do
    context = Map.new(Keyword.get(opts, :context, []))
    byte_offset = Keyword.get(opts, :byte_offset, 0)

    line =
      case(Keyword.get(opts, :line, 1)) do
        {_, _} = line ->
          line

        line ->
          {line, byte_offset}
      end

    case(parse_binary__0(binary, [], [], context, line, byte_offset)) do
      {:ok, acc, rest, context, line, offset} ->
        {:ok, :lists.reverse(acc), rest, context, line, offset}

      {:error, _, _, _, _, _} = error ->
        error
    end
  end

  defp parse_binary__0(rest, acc, stack, context, line, offset) do
    parse_binary__230(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__2(rest, acc, stack, context, line, offset) do
    parse_binary__3(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__3(<<"{{!", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__4(rest, acc, stack, context, comb__line, comb__offset + 3)
  end

  defp parse_binary__3(rest, _acc, _stack, context, line, offset) do
    {:error,
     "expected Comment while processing Function Invocation or Block or Interpolation or utf8 codepoint equal to '{', followed by end of string or utf8 codepoint, and not equal to '{' or utf8 codepoint, and not equal to '{', followed by utf8 codepoint equal to '{', followed by end of string or utf8 codepoint, and not equal to '{' or utf8 codepoint, and not equal to '{' or Comment",
     rest, context, line, offset}
  end

  defp parse_binary__4(<<"}}", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__6(rest, acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__4(rest, acc, stack, context, line, offset) do
    parse_binary__5(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__5(<<byte, rest::binary>>, acc, stack, context, line, offset) do
    parse_binary__4(
      rest,
      acc,
      stack,
      context,
      (
        line = line

        case(byte) do
          10 ->
            {elem(line, 0) + 1, offset + 1}

          _ ->
            line
        end
      ),
      offset + 1
    )
  end

  defp parse_binary__5(rest, _acc, _stack, context, line, offset) do
    {:error,
     "expected Comment while processing Function Invocation or Block or Interpolation or utf8 codepoint equal to '{', followed by end of string or utf8 codepoint, and not equal to '{' or utf8 codepoint, and not equal to '{', followed by utf8 codepoint equal to '{', followed by end of string or utf8 codepoint, and not equal to '{' or utf8 codepoint, and not equal to '{' or Comment",
     rest, context, line, offset}
  end

  defp parse_binary__6(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__7(rest, [:comment] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__7(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__1(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__8(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__2(rest, [], stack, context, line, offset)
  end

  defp parse_binary__9(rest, acc, stack, context, line, offset) do
    parse_binary__10(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__10(rest, acc, stack, context, line, offset) do
    parse_binary__15(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__12(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 123 do
    parse_binary__13(
      rest,
      [x0] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case(x0) do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp parse_binary__12(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    parse_binary__8(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__13(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__11(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__14(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__12(rest, [], stack, context, line, offset)
  end

  defp parse_binary__15(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 123 do
    parse_binary__16(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp parse_binary__15(rest, acc, stack, context, line, offset) do
    parse_binary__14(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__16(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__17("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp parse_binary__16(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 123 do
    parse_binary__17(
      rest,
      [x0] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case(x0) do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp parse_binary__16(rest, acc, stack, context, line, offset) do
    parse_binary__14(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__17(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__11(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__11(rest, acc, stack, context, line, offset) do
    parse_binary__19(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__19(rest, acc, stack, context, line, offset) do
    parse_binary__24(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__21(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 123 do
    parse_binary__22(
      rest,
      [x0] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case(x0) do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp parse_binary__21(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__18(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__22(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__20(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__23(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__21(rest, [], stack, context, line, offset)
  end

  defp parse_binary__24(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 === 123 do
    parse_binary__25(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp parse_binary__24(rest, acc, stack, context, line, offset) do
    parse_binary__23(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__25(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__26("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp parse_binary__25(<<x0::utf8, rest::binary>>, acc, stack, context, comb__line, comb__offset)
       when x0 !== 123 do
    parse_binary__26(
      rest,
      [x0] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case(x0) do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp parse_binary__25(rest, acc, stack, context, line, offset) do
    parse_binary__23(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__26(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__20(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__18(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    parse_binary__27(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__20(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    parse_binary__19(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp parse_binary__27(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__28(
      rest,
      [make_token(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__28(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__1(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__29(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__9(rest, [], stack, context, line, offset)
  end

  defp parse_binary__30(rest, acc, stack, context, line, offset) do
    parse_binary__31(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__31(rest, acc, stack, context, line, offset) do
    parse_binary__132(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__33(rest, acc, stack, context, line, offset) do
    parse_binary__34(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__34(<<"{{&", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__35(rest, [] ++ acc, stack, context, comb__line, comb__offset + 3)
  end

  defp parse_binary__34(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    parse_binary__29(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__35(rest, acc, stack, context, line, offset) do
    parse_binary__36(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__36(rest, acc, stack, context, line, offset) do
    parse_binary__40(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__38(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__37(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__39(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__38(rest, [], stack, context, line, offset)
  end

  defp parse_binary__40(rest, acc, stack, context, line, offset) do
    parse_binary__41(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__41(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__42(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__41(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__39(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__42(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__44(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__42(rest, acc, stack, context, line, offset) do
    parse_binary__43(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__44(rest, acc, stack, context, line, offset) do
    parse_binary__42(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__43(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__45(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__45(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__37(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__37(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__46(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__46(rest, acc, stack, context, line, offset) do
    parse_binary__47(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__47(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__48(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__47(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    parse_binary__29(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__48(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__50(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__48(rest, acc, stack, context, line, offset) do
    parse_binary__49(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__50(rest, acc, stack, context, line, offset) do
    parse_binary__48(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__49(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__51(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__51(rest, acc, stack, context, line, offset) do
    parse_binary__52(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__52(rest, acc, stack, context, line, offset) do
    parse_binary__56(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__54(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__53(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__55(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__54(rest, [], stack, context, line, offset)
  end

  defp parse_binary__56(rest, acc, stack, context, line, offset) do
    parse_binary__57(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__57(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__58(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__57(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__55(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__58(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__60(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__58(rest, acc, stack, context, line, offset) do
    parse_binary__59(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__60(rest, acc, stack, context, line, offset) do
    parse_binary__58(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__59(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__61(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__61(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__53(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__53(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__62(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__62(<<"}}", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__63(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__62(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    parse_binary__29(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__63(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__64(
      rest,
      [
        interpolation_raw:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__64(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__32(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__65(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__33(rest, [], stack, context, line, offset)
  end

  defp parse_binary__66(rest, acc, stack, context, line, offset) do
    parse_binary__67(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__67(<<"{{{", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__68(rest, [] ++ acc, stack, context, comb__line, comb__offset + 3)
  end

  defp parse_binary__67(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__65(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__68(rest, acc, stack, context, line, offset) do
    parse_binary__69(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__69(rest, acc, stack, context, line, offset) do
    parse_binary__73(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__71(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__70(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__72(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__71(rest, [], stack, context, line, offset)
  end

  defp parse_binary__73(rest, acc, stack, context, line, offset) do
    parse_binary__74(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__74(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__75(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__74(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__72(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__75(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__77(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__75(rest, acc, stack, context, line, offset) do
    parse_binary__76(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__77(rest, acc, stack, context, line, offset) do
    parse_binary__75(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__76(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__78(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__78(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__70(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__70(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__79(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__79(rest, acc, stack, context, line, offset) do
    parse_binary__80(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__80(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__81(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__80(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__65(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__81(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__83(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__81(rest, acc, stack, context, line, offset) do
    parse_binary__82(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__83(rest, acc, stack, context, line, offset) do
    parse_binary__81(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__82(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__84(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__84(rest, acc, stack, context, line, offset) do
    parse_binary__85(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__85(rest, acc, stack, context, line, offset) do
    parse_binary__89(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__87(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__86(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__88(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__87(rest, [], stack, context, line, offset)
  end

  defp parse_binary__89(rest, acc, stack, context, line, offset) do
    parse_binary__90(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__90(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__91(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__90(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__88(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__91(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__93(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__91(rest, acc, stack, context, line, offset) do
    parse_binary__92(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__93(rest, acc, stack, context, line, offset) do
    parse_binary__91(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__92(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__94(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__94(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__86(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__86(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__95(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__95(<<"}}}", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__96(rest, [] ++ acc, stack, context, comb__line, comb__offset + 3)
  end

  defp parse_binary__95(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__65(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__96(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__97(
      rest,
      [
        interpolation_raw:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__97(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__32(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__98(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__66(rest, [], stack, context, line, offset)
  end

  defp parse_binary__99(rest, acc, stack, context, line, offset) do
    parse_binary__100(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__100(<<"{{", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__101(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__100(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__98(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__101(rest, acc, stack, context, line, offset) do
    parse_binary__102(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__102(rest, acc, stack, context, line, offset) do
    parse_binary__106(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__104(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__103(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__105(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__104(rest, [], stack, context, line, offset)
  end

  defp parse_binary__106(rest, acc, stack, context, line, offset) do
    parse_binary__107(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__107(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__108(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__107(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__105(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__108(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__110(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__108(rest, acc, stack, context, line, offset) do
    parse_binary__109(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__110(rest, acc, stack, context, line, offset) do
    parse_binary__108(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__109(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__111(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__111(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__103(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__103(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__112(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__112(rest, acc, stack, context, line, offset) do
    parse_binary__113(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__113(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__114(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp parse_binary__113(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__98(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__114(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__116(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__114(rest, acc, stack, context, line, offset) do
    parse_binary__115(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__116(rest, acc, stack, context, line, offset) do
    parse_binary__114(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__115(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__117(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__117(rest, acc, stack, context, line, offset) do
    parse_binary__118(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__118(rest, acc, stack, context, line, offset) do
    parse_binary__122(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__120(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__119(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__121(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__120(rest, [], stack, context, line, offset)
  end

  defp parse_binary__122(rest, acc, stack, context, line, offset) do
    parse_binary__123(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__123(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__124(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__123(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__121(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__124(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__126(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__124(rest, acc, stack, context, line, offset) do
    parse_binary__125(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__126(rest, acc, stack, context, line, offset) do
    parse_binary__124(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__125(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__127(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__127(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__119(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__119(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__128(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__128(<<"}}", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__129(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__128(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__98(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__129(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__130(
      rest,
      [
        interpolation:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__130(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__32(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__131(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__99(rest, [], stack, context, line, offset)
  end

  defp parse_binary__132(rest, acc, stack, context, line, offset) do
    parse_binary__133(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__133(<<"{{", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__134(rest, acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__133(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__131(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__134(rest, acc, stack, context, line, offset) do
    parse_binary__135(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__135(rest, acc, stack, context, line, offset) do
    parse_binary__139(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__137(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__136(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__138(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__137(rest, [], stack, context, line, offset)
  end

  defp parse_binary__139(rest, acc, stack, context, line, offset) do
    parse_binary__140(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__140(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__141(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__140(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__138(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__141(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__143(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__141(rest, acc, stack, context, line, offset) do
    parse_binary__142(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__143(rest, acc, stack, context, line, offset) do
    parse_binary__141(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__142(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__144(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__144(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__136(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__136(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__145(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__145(<<".", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__146(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__145(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__131(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__146(rest, acc, stack, context, line, offset) do
    parse_binary__147(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__147(rest, acc, stack, context, line, offset) do
    parse_binary__151(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__149(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__148(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__150(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__149(rest, [], stack, context, line, offset)
  end

  defp parse_binary__151(rest, acc, stack, context, line, offset) do
    parse_binary__152(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__152(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__153(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__152(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__150(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__153(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__155(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__153(rest, acc, stack, context, line, offset) do
    parse_binary__154(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__155(rest, acc, stack, context, line, offset) do
    parse_binary__153(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__154(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__156(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__156(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__148(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__148(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__157(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__157(<<"}}", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__158(rest, acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__157(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__131(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__158(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__159(rest, [:current_element] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__159(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__32(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__32(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__160(
      rest,
      Enum.map(user_acc, fn var -> make_token(var) end) ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__160(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__1(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__161(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__30(rest, [], stack, context, line, offset)
  end

  defp parse_binary__162(rest, acc, stack, context, line, offset) do
    parse_binary__163(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__163(rest, acc, stack, context, line, offset) do
    parse_binary__164(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__164(rest, acc, stack, context, line, offset) do
    parse_binary__165(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__165(
         <<"{{", x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 35 or x0 === 94 do
    parse_binary__166(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 3)
  end

  defp parse_binary__165(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    parse_binary__161(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__166(rest, acc, stack, context, line, offset) do
    parse_binary__167(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__167(rest, acc, stack, context, line, offset) do
    parse_binary__171(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__169(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__168(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__170(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__169(rest, [], stack, context, line, offset)
  end

  defp parse_binary__171(rest, acc, stack, context, line, offset) do
    parse_binary__172(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__172(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__173(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__172(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__170(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__173(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__175(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__173(rest, acc, stack, context, line, offset) do
    parse_binary__174(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__175(rest, acc, stack, context, line, offset) do
    parse_binary__173(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__174(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__176(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__176(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__168(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__168(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__177(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__177(rest, acc, stack, context, line, offset) do
    parse_binary__178(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__178(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__179(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp parse_binary__178(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    parse_binary__161(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__179(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__181(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__179(rest, acc, stack, context, line, offset) do
    parse_binary__180(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__181(rest, acc, stack, context, line, offset) do
    parse_binary__179(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__180(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__182(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__182(rest, acc, stack, context, line, offset) do
    parse_binary__183(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__183(rest, acc, stack, context, line, offset) do
    parse_binary__187(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__185(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__184(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__186(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__185(rest, [], stack, context, line, offset)
  end

  defp parse_binary__187(rest, acc, stack, context, line, offset) do
    parse_binary__188(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__188(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__189(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__188(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__186(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__189(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__191(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__189(rest, acc, stack, context, line, offset) do
    parse_binary__190(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__191(rest, acc, stack, context, line, offset) do
    parse_binary__189(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__190(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__192(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__192(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__184(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__184(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__193(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__193(<<"}}", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__194(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__193(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    parse_binary__161(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__194(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__195(rest, [:lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__195(<<"{{/", _::binary>> = rest, acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__161(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__195(rest, acc, stack, context, line, offset) do
    parse_binary__196(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__196(rest, acc, stack, context, line, offset) do
    case(parse_binary__0(rest, acc, [], context, line, offset)) do
      {:ok, acc, rest, context, line, offset} ->
        parse_binary__197(rest, acc, stack, context, line, offset)

      {:error, _, _, _, _, _} = error ->
        [_, acc | stack] = stack
        parse_binary__161(rest, acc, stack, context, line, offset)
    end
  end

  defp parse_binary__197(<<"{{/", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__198(rest, [] ++ acc, stack, context, comb__line, comb__offset + 3)
  end

  defp parse_binary__197(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__161(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__198(rest, acc, stack, context, line, offset) do
    parse_binary__199(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__199(rest, acc, stack, context, line, offset) do
    parse_binary__203(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__201(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__200(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__202(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__201(rest, [], stack, context, line, offset)
  end

  defp parse_binary__203(rest, acc, stack, context, line, offset) do
    parse_binary__204(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__204(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__205(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__204(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__202(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__205(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__207(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__205(rest, acc, stack, context, line, offset) do
    parse_binary__206(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__207(rest, acc, stack, context, line, offset) do
    parse_binary__205(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__206(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__208(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__208(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__200(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__200(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__209(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__209(rest, acc, stack, context, line, offset) do
    parse_binary__210(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__210(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__211(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp parse_binary__210(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    parse_binary__161(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__211(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__213(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__211(rest, acc, stack, context, line, offset) do
    parse_binary__212(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__213(rest, acc, stack, context, line, offset) do
    parse_binary__211(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__212(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__214(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__214(rest, acc, stack, context, line, offset) do
    parse_binary__215(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__215(rest, acc, stack, context, line, offset) do
    parse_binary__219(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__217(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__216(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__218(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__217(rest, [], stack, context, line, offset)
  end

  defp parse_binary__219(rest, acc, stack, context, line, offset) do
    parse_binary__220(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__220(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__221(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__220(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__218(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__221(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__223(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__221(rest, acc, stack, context, line, offset) do
    parse_binary__222(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__223(rest, acc, stack, context, line, offset) do
    parse_binary__221(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__222(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__224(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__224(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__216(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__216(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__225(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__225(<<"}}", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__226(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__225(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__161(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__226(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__227(
      rest,
      [block: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__227(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__228(
      rest,
      Enum.map(user_acc, fn var -> make_token(var) end) ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__228(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__1(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__229(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__162(rest, [], stack, context, line, offset)
  end

  defp parse_binary__230(rest, acc, stack, context, line, offset) do
    parse_binary__231(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__231(rest, acc, stack, context, line, offset) do
    parse_binary__232(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__232(<<"{{", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__233(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__232(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__229(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__233(rest, acc, stack, context, line, offset) do
    parse_binary__234(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__234(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__235(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp parse_binary__234(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    parse_binary__229(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__235(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__237(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__235(rest, acc, stack, context, line, offset) do
    parse_binary__236(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__237(rest, acc, stack, context, line, offset) do
    parse_binary__235(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__236(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__238(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__238(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__239(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__238(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__229(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__239(rest, acc, stack, context, line, offset) do
    parse_binary__240(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__240(rest, acc, stack, context, line, offset) do
    parse_binary__241(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__241(<<"='", _::binary>> = rest, acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    parse_binary__229(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__241(rest, acc, stack, context, line, offset) do
    parse_binary__242(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__242(rest, acc, stack, context, line, offset) do
    parse_binary__243(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__243(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__244(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp parse_binary__243(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    parse_binary__229(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__244(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__246(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__244(rest, acc, stack, context, line, offset) do
    parse_binary__245(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__246(rest, acc, stack, context, line, offset) do
    parse_binary__244(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__245(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__247(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__247(<<"='", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__248(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__247(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    parse_binary__229(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__248(rest, acc, stack, context, line, offset) do
    parse_binary__249(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__249(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 39 do
    parse_binary__250(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case(x0) do
          10 ->
            {elem(line, 0) + 1, comb__offset + 1}

          _ ->
            line
        end
      ),
      comb__offset + 1
    )
  end

  defp parse_binary__249(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    parse_binary__229(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__250(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 39 do
    parse_binary__252(
      rest,
      [x0] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case(x0) do
          10 ->
            {elem(line, 0) + 1, comb__offset + 1}

          _ ->
            line
        end
      ),
      comb__offset + 1
    )
  end

  defp parse_binary__250(rest, acc, stack, context, line, offset) do
    parse_binary__251(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__252(rest, acc, stack, context, line, offset) do
    parse_binary__250(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__251(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__253(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__253(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__254(
      rest,
      [argument: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__254(<<"'", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__255(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__254(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    parse_binary__229(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__255(rest, acc, stack, context, line, offset) do
    parse_binary__256(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__256(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__257(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__256(<<rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__257(rest, acc, stack, context, comb__line, comb__offset)
  end

  defp parse_binary__257(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__258(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__258(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__259(
      rest,
      Enum.map(user_acc, fn var -> make_token(var) end) ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__259(rest, acc, stack, context, line, offset) do
    parse_binary__261(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__261(rest, acc, stack, context, line, offset) do
    parse_binary__262(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__262(rest, acc, stack, context, line, offset) do
    parse_binary__263(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__263(<<"='", _::binary>> = rest, acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__260(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__263(rest, acc, stack, context, line, offset) do
    parse_binary__264(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__264(rest, acc, stack, context, line, offset) do
    parse_binary__265(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__265(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__266(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp parse_binary__265(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    parse_binary__260(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__266(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__268(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__266(rest, acc, stack, context, line, offset) do
    parse_binary__267(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__268(rest, acc, stack, context, line, offset) do
    parse_binary__266(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__267(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__269(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__269(<<"='", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__270(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__269(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__260(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__270(rest, acc, stack, context, line, offset) do
    parse_binary__271(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__271(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 39 do
    parse_binary__272(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case(x0) do
          10 ->
            {elem(line, 0) + 1, comb__offset + 1}

          _ ->
            line
        end
      ),
      comb__offset + 1
    )
  end

  defp parse_binary__271(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    parse_binary__260(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__272(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 39 do
    parse_binary__274(
      rest,
      [x0] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case(x0) do
          10 ->
            {elem(line, 0) + 1, comb__offset + 1}

          _ ->
            line
        end
      ),
      comb__offset + 1
    )
  end

  defp parse_binary__272(rest, acc, stack, context, line, offset) do
    parse_binary__273(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__274(rest, acc, stack, context, line, offset) do
    parse_binary__272(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__273(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__275(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__275(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__276(
      rest,
      [argument: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__276(<<"'", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__277(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__276(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__260(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__277(rest, acc, stack, context, line, offset) do
    parse_binary__278(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__278(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__279(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__278(<<rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__279(rest, acc, stack, context, comb__line, comb__offset)
  end

  defp parse_binary__279(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__280(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__280(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__281(
      rest,
      Enum.map(user_acc, fn var -> make_token(var) end) ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__260(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    parse_binary__282(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__281(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    parse_binary__261(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp parse_binary__282(<<"}}", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__283(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__282(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__229(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__283(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__284(
      rest,
      [function: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__284(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__285(
      rest,
      Enum.map(user_acc, fn var -> make_token(var) end) ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__285(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__1(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__1(rest, acc, stack, context, line, offset) do
    parse_binary__287(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__287(rest, acc, stack, context, line, offset) do
    parse_binary__517(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__289(rest, acc, stack, context, line, offset) do
    parse_binary__290(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__290(<<"{{!", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__291(rest, acc, stack, context, comb__line, comb__offset + 3)
  end

  defp parse_binary__290(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    parse_binary__286(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__291(<<"}}", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__293(rest, acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__291(rest, acc, stack, context, line, offset) do
    parse_binary__292(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__292(<<byte, rest::binary>>, acc, stack, context, line, offset) do
    parse_binary__291(
      rest,
      acc,
      stack,
      context,
      (
        line = line

        case(byte) do
          10 ->
            {elem(line, 0) + 1, offset + 1}

          _ ->
            line
        end
      ),
      offset + 1
    )
  end

  defp parse_binary__292(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    parse_binary__286(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__293(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__294(rest, [:comment] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__294(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__288(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__295(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__289(rest, [], stack, context, line, offset)
  end

  defp parse_binary__296(rest, acc, stack, context, line, offset) do
    parse_binary__297(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__297(rest, acc, stack, context, line, offset) do
    parse_binary__302(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__299(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 123 do
    parse_binary__300(
      rest,
      [x0] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case(x0) do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp parse_binary__299(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    parse_binary__295(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__300(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__298(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__301(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__299(rest, [], stack, context, line, offset)
  end

  defp parse_binary__302(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 123 do
    parse_binary__303(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp parse_binary__302(rest, acc, stack, context, line, offset) do
    parse_binary__301(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__303(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__304("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp parse_binary__303(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 123 do
    parse_binary__304(
      rest,
      [x0] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case(x0) do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp parse_binary__303(rest, acc, stack, context, line, offset) do
    parse_binary__301(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__304(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__298(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__298(rest, acc, stack, context, line, offset) do
    parse_binary__306(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__306(rest, acc, stack, context, line, offset) do
    parse_binary__311(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__308(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 123 do
    parse_binary__309(
      rest,
      [x0] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case(x0) do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp parse_binary__308(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__305(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__309(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__307(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__310(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__308(rest, [], stack, context, line, offset)
  end

  defp parse_binary__311(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 123 do
    parse_binary__312(
      rest,
      [x0] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp parse_binary__311(rest, acc, stack, context, line, offset) do
    parse_binary__310(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__312(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__313("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp parse_binary__312(
         <<x0::utf8, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 123 do
    parse_binary__313(
      rest,
      [x0] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case(x0) do
          10 ->
            {elem(line, 0) + 1, comb__offset + byte_size(<<x0::utf8>>)}

          _ ->
            line
        end
      ),
      comb__offset + byte_size(<<x0::utf8>>)
    )
  end

  defp parse_binary__312(rest, acc, stack, context, line, offset) do
    parse_binary__310(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__313(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__307(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__305(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    parse_binary__314(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__307(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    parse_binary__306(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp parse_binary__314(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__315(
      rest,
      [make_token(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__315(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__288(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__316(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__296(rest, [], stack, context, line, offset)
  end

  defp parse_binary__317(rest, acc, stack, context, line, offset) do
    parse_binary__318(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__318(rest, acc, stack, context, line, offset) do
    parse_binary__419(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__320(rest, acc, stack, context, line, offset) do
    parse_binary__321(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__321(<<"{{&", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__322(rest, [] ++ acc, stack, context, comb__line, comb__offset + 3)
  end

  defp parse_binary__321(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    parse_binary__316(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__322(rest, acc, stack, context, line, offset) do
    parse_binary__323(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__323(rest, acc, stack, context, line, offset) do
    parse_binary__327(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__325(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__324(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__326(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__325(rest, [], stack, context, line, offset)
  end

  defp parse_binary__327(rest, acc, stack, context, line, offset) do
    parse_binary__328(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__328(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__329(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__328(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__326(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__329(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__331(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__329(rest, acc, stack, context, line, offset) do
    parse_binary__330(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__331(rest, acc, stack, context, line, offset) do
    parse_binary__329(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__330(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__332(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__332(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__324(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__324(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__333(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__333(rest, acc, stack, context, line, offset) do
    parse_binary__334(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__334(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__335(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp parse_binary__334(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    parse_binary__316(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__335(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__337(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__335(rest, acc, stack, context, line, offset) do
    parse_binary__336(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__337(rest, acc, stack, context, line, offset) do
    parse_binary__335(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__336(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__338(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__338(rest, acc, stack, context, line, offset) do
    parse_binary__339(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__339(rest, acc, stack, context, line, offset) do
    parse_binary__343(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__341(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__340(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__342(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__341(rest, [], stack, context, line, offset)
  end

  defp parse_binary__343(rest, acc, stack, context, line, offset) do
    parse_binary__344(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__344(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__345(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__344(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__342(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__345(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__347(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__345(rest, acc, stack, context, line, offset) do
    parse_binary__346(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__347(rest, acc, stack, context, line, offset) do
    parse_binary__345(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__346(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__348(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__348(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__340(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__340(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__349(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__349(<<"}}", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__350(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__349(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    parse_binary__316(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__350(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__351(
      rest,
      [
        interpolation_raw:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__351(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__319(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__352(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__320(rest, [], stack, context, line, offset)
  end

  defp parse_binary__353(rest, acc, stack, context, line, offset) do
    parse_binary__354(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__354(<<"{{{", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__355(rest, [] ++ acc, stack, context, comb__line, comb__offset + 3)
  end

  defp parse_binary__354(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__352(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__355(rest, acc, stack, context, line, offset) do
    parse_binary__356(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__356(rest, acc, stack, context, line, offset) do
    parse_binary__360(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__358(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__357(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__359(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__358(rest, [], stack, context, line, offset)
  end

  defp parse_binary__360(rest, acc, stack, context, line, offset) do
    parse_binary__361(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__361(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__362(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__361(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__359(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__362(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__364(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__362(rest, acc, stack, context, line, offset) do
    parse_binary__363(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__364(rest, acc, stack, context, line, offset) do
    parse_binary__362(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__363(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__365(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__365(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__357(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__357(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__366(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__366(rest, acc, stack, context, line, offset) do
    parse_binary__367(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__367(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__368(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp parse_binary__367(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__352(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__368(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__370(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__368(rest, acc, stack, context, line, offset) do
    parse_binary__369(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__370(rest, acc, stack, context, line, offset) do
    parse_binary__368(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__369(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__371(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__371(rest, acc, stack, context, line, offset) do
    parse_binary__372(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__372(rest, acc, stack, context, line, offset) do
    parse_binary__376(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__374(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__373(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__375(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__374(rest, [], stack, context, line, offset)
  end

  defp parse_binary__376(rest, acc, stack, context, line, offset) do
    parse_binary__377(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__377(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__378(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__377(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__375(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__378(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__380(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__378(rest, acc, stack, context, line, offset) do
    parse_binary__379(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__380(rest, acc, stack, context, line, offset) do
    parse_binary__378(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__379(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__381(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__381(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__373(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__373(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__382(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__382(<<"}}}", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__383(rest, [] ++ acc, stack, context, comb__line, comb__offset + 3)
  end

  defp parse_binary__382(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__352(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__383(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__384(
      rest,
      [
        interpolation_raw:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__384(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__319(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__385(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__353(rest, [], stack, context, line, offset)
  end

  defp parse_binary__386(rest, acc, stack, context, line, offset) do
    parse_binary__387(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__387(<<"{{", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__388(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__387(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__385(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__388(rest, acc, stack, context, line, offset) do
    parse_binary__389(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__389(rest, acc, stack, context, line, offset) do
    parse_binary__393(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__391(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__390(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__392(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__391(rest, [], stack, context, line, offset)
  end

  defp parse_binary__393(rest, acc, stack, context, line, offset) do
    parse_binary__394(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__394(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__395(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__394(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__392(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__395(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__397(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__395(rest, acc, stack, context, line, offset) do
    parse_binary__396(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__397(rest, acc, stack, context, line, offset) do
    parse_binary__395(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__396(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__398(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__398(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__390(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__390(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__399(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__399(rest, acc, stack, context, line, offset) do
    parse_binary__400(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__400(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__401(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp parse_binary__400(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__385(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__401(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__403(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__401(rest, acc, stack, context, line, offset) do
    parse_binary__402(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__403(rest, acc, stack, context, line, offset) do
    parse_binary__401(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__402(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__404(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__404(rest, acc, stack, context, line, offset) do
    parse_binary__405(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__405(rest, acc, stack, context, line, offset) do
    parse_binary__409(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__407(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__406(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__408(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__407(rest, [], stack, context, line, offset)
  end

  defp parse_binary__409(rest, acc, stack, context, line, offset) do
    parse_binary__410(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__410(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__411(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__410(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__408(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__411(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__413(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__411(rest, acc, stack, context, line, offset) do
    parse_binary__412(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__413(rest, acc, stack, context, line, offset) do
    parse_binary__411(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__412(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__414(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__414(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__406(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__406(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__415(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__415(<<"}}", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__416(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__415(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__385(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__416(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__417(
      rest,
      [
        interpolation:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__417(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__319(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__418(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__386(rest, [], stack, context, line, offset)
  end

  defp parse_binary__419(rest, acc, stack, context, line, offset) do
    parse_binary__420(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__420(<<"{{", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__421(rest, acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__420(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__418(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__421(rest, acc, stack, context, line, offset) do
    parse_binary__422(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__422(rest, acc, stack, context, line, offset) do
    parse_binary__426(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__424(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__423(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__425(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__424(rest, [], stack, context, line, offset)
  end

  defp parse_binary__426(rest, acc, stack, context, line, offset) do
    parse_binary__427(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__427(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__428(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__427(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__425(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__428(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__430(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__428(rest, acc, stack, context, line, offset) do
    parse_binary__429(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__430(rest, acc, stack, context, line, offset) do
    parse_binary__428(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__429(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__431(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__431(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__423(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__423(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__432(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__432(<<".", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__433(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__432(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__418(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__433(rest, acc, stack, context, line, offset) do
    parse_binary__434(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__434(rest, acc, stack, context, line, offset) do
    parse_binary__438(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__436(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__435(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__437(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__436(rest, [], stack, context, line, offset)
  end

  defp parse_binary__438(rest, acc, stack, context, line, offset) do
    parse_binary__439(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__439(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__440(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__439(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__437(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__440(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__442(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__440(rest, acc, stack, context, line, offset) do
    parse_binary__441(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__442(rest, acc, stack, context, line, offset) do
    parse_binary__440(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__441(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__443(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__443(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__435(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__435(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__444(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__444(<<"}}", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__445(rest, acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__444(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__418(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__445(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__446(rest, [:current_element] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__446(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__319(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__319(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__447(
      rest,
      Enum.map(user_acc, fn var -> make_token(var) end) ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__447(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__288(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__448(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__317(rest, [], stack, context, line, offset)
  end

  defp parse_binary__449(rest, acc, stack, context, line, offset) do
    parse_binary__450(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__450(rest, acc, stack, context, line, offset) do
    parse_binary__451(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__451(rest, acc, stack, context, line, offset) do
    parse_binary__452(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__452(
         <<"{{", x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 35 or x0 === 94 do
    parse_binary__453(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 3)
  end

  defp parse_binary__452(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    parse_binary__448(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__453(rest, acc, stack, context, line, offset) do
    parse_binary__454(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__454(rest, acc, stack, context, line, offset) do
    parse_binary__458(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__456(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__455(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__457(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__456(rest, [], stack, context, line, offset)
  end

  defp parse_binary__458(rest, acc, stack, context, line, offset) do
    parse_binary__459(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__459(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__460(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__459(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__457(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__460(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__462(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__460(rest, acc, stack, context, line, offset) do
    parse_binary__461(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__462(rest, acc, stack, context, line, offset) do
    parse_binary__460(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__461(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__463(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__463(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__455(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__455(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__464(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__464(rest, acc, stack, context, line, offset) do
    parse_binary__465(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__465(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__466(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp parse_binary__465(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    parse_binary__448(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__466(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__468(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__466(rest, acc, stack, context, line, offset) do
    parse_binary__467(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__468(rest, acc, stack, context, line, offset) do
    parse_binary__466(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__467(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__469(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__469(rest, acc, stack, context, line, offset) do
    parse_binary__470(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__470(rest, acc, stack, context, line, offset) do
    parse_binary__474(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__472(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__471(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__473(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__472(rest, [], stack, context, line, offset)
  end

  defp parse_binary__474(rest, acc, stack, context, line, offset) do
    parse_binary__475(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__475(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__476(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__475(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__473(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__476(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__478(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__476(rest, acc, stack, context, line, offset) do
    parse_binary__477(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__478(rest, acc, stack, context, line, offset) do
    parse_binary__476(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__477(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__479(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__479(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__471(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__471(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__480(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__480(<<"}}", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__481(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__480(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    parse_binary__448(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__481(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__482(rest, [:lists.reverse(user_acc)] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__482(<<"{{/", _::binary>> = rest, acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__448(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__482(rest, acc, stack, context, line, offset) do
    parse_binary__483(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__483(rest, acc, stack, context, line, offset) do
    case(parse_binary__0(rest, acc, [], context, line, offset)) do
      {:ok, acc, rest, context, line, offset} ->
        parse_binary__484(rest, acc, stack, context, line, offset)

      {:error, _, _, _, _, _} = error ->
        [_, acc | stack] = stack
        parse_binary__448(rest, acc, stack, context, line, offset)
    end
  end

  defp parse_binary__484(<<"{{/", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__485(rest, [] ++ acc, stack, context, comb__line, comb__offset + 3)
  end

  defp parse_binary__484(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__448(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__485(rest, acc, stack, context, line, offset) do
    parse_binary__486(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__486(rest, acc, stack, context, line, offset) do
    parse_binary__490(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__488(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__487(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__489(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__488(rest, [], stack, context, line, offset)
  end

  defp parse_binary__490(rest, acc, stack, context, line, offset) do
    parse_binary__491(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__491(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__492(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__491(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__489(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__492(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__494(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__492(rest, acc, stack, context, line, offset) do
    parse_binary__493(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__494(rest, acc, stack, context, line, offset) do
    parse_binary__492(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__493(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__495(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__495(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__487(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__487(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__496(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__496(rest, acc, stack, context, line, offset) do
    parse_binary__497(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__497(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__498(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp parse_binary__497(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    parse_binary__448(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__498(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__500(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__498(rest, acc, stack, context, line, offset) do
    parse_binary__499(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__500(rest, acc, stack, context, line, offset) do
    parse_binary__498(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__499(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__501(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__501(rest, acc, stack, context, line, offset) do
    parse_binary__502(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__502(rest, acc, stack, context, line, offset) do
    parse_binary__506(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__504(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__503(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__505(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__504(rest, [], stack, context, line, offset)
  end

  defp parse_binary__506(rest, acc, stack, context, line, offset) do
    parse_binary__507(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__507(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__508(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__507(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__505(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__508(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 32 do
    parse_binary__510(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__508(rest, acc, stack, context, line, offset) do
    parse_binary__509(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__510(rest, acc, stack, context, line, offset) do
    parse_binary__508(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__509(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__511(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__511(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__503(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__503(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__512(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__512(<<"}}", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__513(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__512(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__448(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__513(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__514(
      rest,
      [block: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__514(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__515(
      rest,
      Enum.map(user_acc, fn var -> make_token(var) end) ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__515(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__288(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__516(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    parse_binary__449(rest, [], stack, context, line, offset)
  end

  defp parse_binary__517(rest, acc, stack, context, line, offset) do
    parse_binary__518(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__518(rest, acc, stack, context, line, offset) do
    parse_binary__519(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__519(<<"{{", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__520(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__519(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__516(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__520(rest, acc, stack, context, line, offset) do
    parse_binary__521(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__521(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__522(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp parse_binary__521(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    parse_binary__516(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__522(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__524(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__522(rest, acc, stack, context, line, offset) do
    parse_binary__523(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__524(rest, acc, stack, context, line, offset) do
    parse_binary__522(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__523(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__525(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__525(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__526(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__525(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__516(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__526(rest, acc, stack, context, line, offset) do
    parse_binary__527(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__527(rest, acc, stack, context, line, offset) do
    parse_binary__528(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__528(<<"='", _::binary>> = rest, acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    parse_binary__516(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__528(rest, acc, stack, context, line, offset) do
    parse_binary__529(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__529(rest, acc, stack, context, line, offset) do
    parse_binary__530(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__530(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__531(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp parse_binary__530(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    parse_binary__516(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__531(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__533(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__531(rest, acc, stack, context, line, offset) do
    parse_binary__532(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__533(rest, acc, stack, context, line, offset) do
    parse_binary__531(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__532(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__534(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__534(<<"='", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__535(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__534(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    parse_binary__516(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__535(rest, acc, stack, context, line, offset) do
    parse_binary__536(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__536(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 39 do
    parse_binary__537(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case(x0) do
          10 ->
            {elem(line, 0) + 1, comb__offset + 1}

          _ ->
            line
        end
      ),
      comb__offset + 1
    )
  end

  defp parse_binary__536(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    parse_binary__516(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__537(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 39 do
    parse_binary__539(
      rest,
      [x0] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case(x0) do
          10 ->
            {elem(line, 0) + 1, comb__offset + 1}

          _ ->
            line
        end
      ),
      comb__offset + 1
    )
  end

  defp parse_binary__537(rest, acc, stack, context, line, offset) do
    parse_binary__538(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__539(rest, acc, stack, context, line, offset) do
    parse_binary__537(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__538(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__540(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__540(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__541(
      rest,
      [argument: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__541(<<"'", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__542(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__541(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    parse_binary__516(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__542(rest, acc, stack, context, line, offset) do
    parse_binary__543(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__543(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__544(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__543(<<rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__544(rest, acc, stack, context, comb__line, comb__offset)
  end

  defp parse_binary__544(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__545(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__545(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__546(
      rest,
      Enum.map(user_acc, fn var -> make_token(var) end) ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__546(rest, acc, stack, context, line, offset) do
    parse_binary__548(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp parse_binary__548(rest, acc, stack, context, line, offset) do
    parse_binary__549(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__549(rest, acc, stack, context, line, offset) do
    parse_binary__550(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__550(<<"='", _::binary>> = rest, acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__547(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__550(rest, acc, stack, context, line, offset) do
    parse_binary__551(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__551(rest, acc, stack, context, line, offset) do
    parse_binary__552(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__552(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__553(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp parse_binary__552(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    parse_binary__547(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__553(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) or
              x0 === 95 or x0 === 46 do
    parse_binary__555(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__553(rest, acc, stack, context, line, offset) do
    parse_binary__554(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__555(rest, acc, stack, context, line, offset) do
    parse_binary__553(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__554(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__556(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__556(<<"='", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__557(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__556(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__547(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__557(rest, acc, stack, context, line, offset) do
    parse_binary__558(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__558(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 39 do
    parse_binary__559(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case(x0) do
          10 ->
            {elem(line, 0) + 1, comb__offset + 1}

          _ ->
            line
        end
      ),
      comb__offset + 1
    )
  end

  defp parse_binary__558(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    parse_binary__547(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__559(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 !== 39 do
    parse_binary__561(
      rest,
      [x0] ++ acc,
      stack,
      context,
      (
        line = comb__line

        case(x0) do
          10 ->
            {elem(line, 0) + 1, comb__offset + 1}

          _ ->
            line
        end
      ),
      comb__offset + 1
    )
  end

  defp parse_binary__559(rest, acc, stack, context, line, offset) do
    parse_binary__560(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__561(rest, acc, stack, context, line, offset) do
    parse_binary__559(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__560(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__562(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__562(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__563(
      rest,
      [argument: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__563(<<"'", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__564(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__563(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    parse_binary__547(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__564(rest, acc, stack, context, line, offset) do
    parse_binary__565(rest, [], [acc | stack], context, line, offset)
  end

  defp parse_binary__565(<<" ", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__566(rest, acc, stack, context, comb__line, comb__offset + 1)
  end

  defp parse_binary__565(<<rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__566(rest, acc, stack, context, comb__line, comb__offset)
  end

  defp parse_binary__566(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc
    parse_binary__567(rest, [] ++ acc, stack, context, line, offset)
  end

  defp parse_binary__567(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__568(
      rest,
      Enum.map(user_acc, fn var -> make_token(var) end) ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__547(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    parse_binary__569(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__568(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    parse_binary__548(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp parse_binary__569(<<"}}", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    parse_binary__570(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp parse_binary__569(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    parse_binary__516(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__570(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__571(
      rest,
      [function: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__571(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    parse_binary__572(
      rest,
      Enum.map(user_acc, fn var -> make_token(var) end) ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp parse_binary__572(rest, acc, [_, previous_acc | stack], context, line, offset) do
    parse_binary__288(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp parse_binary__286(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    parse_binary__573(rest, acc, stack, context, line, offset)
  end

  defp parse_binary__288(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    parse_binary__287(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp parse_binary__573(rest, acc, _stack, context, line, offset) do
    {:ok, acc, rest, context, line, offset}
  end
end
