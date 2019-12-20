Definitions.

% Helper expressions (non-token)
ValidInTagName = [A-Za-z0-9\._]
ValidTagAttributeName = [A-Za-z\-]
ValidTagAttributeValue = [A-Za-z0-9\s="\-/:;,\.?\(\)@\}\{_]
ValidTagAttribute = {ValidTagAttributeName}+=("|')?{ValidTagAttributeValue}+("|')?
ValidTags = (\s{ValidTagAttribute})*
ValidInsideTag = [A-Za-z0-9\w\s="\-/@#:;,\.\'{}\(\)\[\]&\|\*]

StartToken = \{\{
CloseToken = \}\}
OpenParen = \(
CloseParen = \)
ValidInsideParens = [^\)]+

ArgumentList = {OpenParen}{ValidInsideParens}+{CloseParen}
FunctionCall = {StartToken}{ValidInTagName}+{OpenParen}{ValidInsideParens}+{CloseParen}{CloseToken}

Whitespace = [\r\s\n\t]+

INTERPOLATION = \{\{{ValidInTagName}+\}\}
FUNCTION = {FunctionCall}
START_TAG = \{\{\#[A-Za-z0-9\w\s\.]+\}\}
END_TAG   = \{\{/[A-Za-z0-9\w\s\.]+\}\}
CHARACTER = .|\r\n|\n

Rules.

{INTERPOLATION} : {token, {interpolation, TokenLine, TokenChars}}.
{START_TAG} : {token, {start_tag, TokenLine, TokenChars}}.
{END_TAG} : {token, {end_tag, TokenLine, TokenChars}}.
{CHARACTER} : {token, {char, TokenLine, TokenChars}}.
{FUNCTION} : {token, {function, TokenLine, TokenChars}}.

Erlang code.
