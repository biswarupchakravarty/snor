Nonterminals
template
chars
nodes node
quot_opened
quote_proper
.

Terminals
char
space
tag_close
quotation
assignment
quoted_value
interpolation
function_tag_start
.

Rootsymbol
template.


template -> nodes : '$1'.

nodes -> node : ['$1'].
nodes -> node nodes : ['$1'|'$2'].

quot_opened -> char quotation : open_quot(unwrap('$2')).
quot_opened -> char quot_opened : add_c_to_q([unwrap('$1')|'$2']).
quote_proper -> quot_opened quotation : {quoted, '$1'}.
% node -> quote_proper : {quoted, ["Q", '$1']}.

node -> quote_proper tag_close char : ['$1', "}}", unwrap('$3')].

node -> chars : '$1'.
chars -> char chars : unicode:characters_to_binary([unwrap('$1')|'$2']).
chars -> char : unicode:characters_to_binary(unwrap('$1')).
chars -> char function_tag_start : [unwrap('$1')|"{{"].
chars -> assignment chars : ["="|unwrap('$1')].
chars -> quotation chars : ["'"|unwrap('$1')].
chars -> chars space : c_to_b(['$1'|" "]).
chars -> chars quotation : c_to_b(['$1'|"'"]).
chars -> chars assignment : c_to_b(['$1'|"="]).
chars -> chars function_tag_start : c_to_b(['$1'|"{{"]).

% simple interpolation
node -> interpolation : {interpolate, xx(remove_braces(unwrap('$1')))}.


Erlang code.

unwrap({_,_,V}) -> V.

open_quot(X) -> io:format("opened normal q~n"), c_to_b(X).
add_c_to_q(X) -> io:format("Adding to quote -- ~s~n", [X]), c_to_b(X).
open_a_quot(X) -> io:format("opened assigned q~n"), c_to_b(X).

c_to_b(V) -> unicode:characters_to_binary(V).

split_args({_,_,V}) -> string:split(V, "=\"").
xx(X) -> string:split(X, "\.", all).
remove_braces(S) -> [_, _, A] = string:replace(S, "{{", ""),
[B, _, _] = string:replace(A, "}}", ""),
B.
