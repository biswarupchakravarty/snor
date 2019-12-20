Nonterminals
template
chars
argument
% arg_pair
nodes node.

Terminals
char
key
% arg
function
interpolation
end_tag start_tag
'='.

Rootsymbol
template.


template -> nodes : '$1'.

nodes -> node : ['$1'].
nodes -> node nodes : ['$1'|'$2'].

node -> start_tag nodes end_tag : {with_scope, unwrap('$1'), '$2'}.

node -> function : {function, unwrap('$1')}.
node -> interpolation : {interpolate, unwrap('$1')}.

node -> chars : '$1'.
chars -> char chars : unicode:characters_to_binary([unwrap('$1')|'$2']).
chars -> char : unicode:characters_to_binary(unwrap('$1')).

Erlang code.

unwrap({_,_,V}) -> V.
split_args({_,_,V}) -> string:split(V, "=\"").
