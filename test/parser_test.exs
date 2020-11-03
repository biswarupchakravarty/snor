defmodule Snor.ParserTest do
  use ExUnit.Case, async: true

  doctest Snor.Parser
  alias Snor.Parser

  describe "variables" do
    test "variable name" do
      assert Parser.parse_binary("{{hello_world}}") ==
               {:ok, [%{interpolation: ["hello_world"], raw: false}], "", %{}, {1, 0}, 15}
    end

    test "variable name surrounding whitespace" do
      {:ok, tokens, "", %{}, {1, 0}, _} = Parser.parse_binary("{{ hello_world }}")
      assert tokens == [%{interpolation: ["hello_world"], raw: false}]
    end

    test "variable name with ampersand" do
      {:ok, tokens, "", %{}, {1, 0}, _} = Parser.parse_binary("{{&hello_world}}")
      assert tokens == [%{interpolation: ["hello_world"], raw: true}]
    end

    test "triple mustache" do
      {:ok, tokens, "", %{}, {1, 0}, _} = Parser.parse_binary("{{{ hello_world }}}")
      assert tokens == [%{interpolation: ["hello_world"], raw: true}]
    end

    test "dot syntax" do
      result = Parser.parse_binary("Hello {{person.name}}")
      {:ok, tokens, "", %{}, _, _} = result
      assert tokens == [%{plaintext: "Hello "}, %{interpolation: ["person", "name"], raw: false}]
    end

    test "plaintext" do
      assert Parser.parse_binary("Hello world") ==
               {:ok, [%{plaintext: "Hello world"}], "", %{}, {1, 0}, 11}
    end

    test "plaintext with braces" do
      {:ok, tokens, "", _, _} = Parser.parse_binary("{world}")
      assert tokens == [%{plaintext: "{world}"}]
    end

    test "both" do
      result = Parser.parse_binary("Hello {{name}}")
      {:ok, tokens, "", %{}, _, _} = result
      assert tokens == [%{plaintext: "Hello "}, %{interpolation: ["name"], raw: false}]
    end
  end

  describe "blocks" do
    test "with inner interpolation" do
      result = Parser.parse_binary("{{#person}}Hello, {{name}}{{/person}}")
      {:ok, [block], "", %{}, _, _} = result

      assert block == %{
               block: "person",
               negative: false,
               tokens: [%{plaintext: "Hello, "}, %{interpolation: ["name"], raw: false}]
             }
    end

    test "dotted path" do
      result = Parser.parse_binary("{{#list.items}}({{.}}){{/list.items}}")
      {:ok, tokens, "", _, _, _} = result

      assert tokens == [
               %{
                 block: "list.items",
                 negative: false,
                 tokens: [%{plaintext: "("}, :current_element, %{plaintext: ")"}]
               }
             ]
    end

    test "implicit dot" do
      result = Parser.parse_binary("{{#list}}({{.}}){{/list}}")
      {:ok, tokens, "", _, _, _} = result

      assert tokens == [
               %{
                 block: "list",
                 negative: false,
                 tokens: [%{plaintext: "("}, :current_element, %{plaintext: ")"}]
               }
             ]
    end

    test "with more nesting" do
      result =
        Parser.parse_binary("{{#person}}Hello, {{#details}}you {{type}}{{/details}}{{/person}}")

      {:ok, [block], "", %{}, _, _} = result

      assert block == %{
               block: "person",
               negative: false,
               tokens: [
                 %{plaintext: "Hello, "},
                 %{
                   block: "details",
                   negative: false,
                   tokens: [%{plaintext: "you "}, %{interpolation: ["type"], raw: false}]
                 }
               ]
             }
    end

    test "negative" do
      result = Parser.parse_binary("{{^list}}Yay lists!{{/list}}")
      {:ok, [block], "", %{}, _, _} = result
      assert block == %{block: "list", negative: true, tokens: [%{plaintext: "Yay lists!"}]}
    end

    test "with incorrect closing " do
      assert_raise(MatchError, fn ->
        assert Parser.parse_binary("{{#person}}Hello, {{name}}{{/presona}}") == []
      end)
    end
  end

  describe "comments" do
    test "ignores tokens" do
      {:ok, tokens, "", %{}, _, _} = Parser.parse_binary("Hello {{!function_name name='a'}}")
      assert tokens == [%{plaintext: "Hello "}, :comment]
    end
  end

  describe "functions" do
    test "with 1 arg" do
      {:ok, [func], "", %{}, _, _} = Parser.parse_binary("{{function_name name='a'}}")
      assert func == %{:function => "function_name", "name" => [%{plaintext: "a"}]}
    end

    test "with 2 args" do
      {:ok, [func], "", %{}, _, _} = Parser.parse_binary("{{f a='1' b='2'}}")
      assert func == %{:function => "f", "a" => [%{plaintext: "1"}], "b" => [%{plaintext: "2"}]}
    end

    test "with interpolation" do
      {:ok, [func], "", %{}, _, _} = Parser.parse_binary("{{f a='1' b='{{person.name}}'}}")

      assert func == %{
               :function => "f",
               "a" => [%{plaintext: "1"}],
               "b" => [%{interpolation: ["person", "name"], raw: false}]
             }
    end
  end
end
