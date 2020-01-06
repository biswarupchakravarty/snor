Definitions.

% Helper expressions (non-token)
ValidInTagName = [A-Za-z0-9\._]
ValidTagAttributeName = [A-Za-z\-]
ValidTagAttributeValue = [A-Za-z0-9\s="\-/:;,\.?\(\)@\}\{_]
ValidTagAttribute = {ValidTagAttributeName}+=("|')?{ValidTagAttributeValue}+("|')?
ValidTags = (\s{ValidTagAttribute})*
ValidInsideTag = [A-Za-z0-9\w\s="\-/@#:;,\.\'{}\(\)\[\]&\|\*]

OpenParen = \(
CloseParen = \)
ValidInsideParens = [^\)]+

ArgumentList = {OpenParen}{ValidInsideParens}+{CloseParen}
FunctionCall = {StartToken}{ValidInTagName}+{OpenParen}{ValidInsideParens}+{CloseParen}{CloseToken}

Whitespace = [\r\s\n\t]+

% INTERPOLATION = \{\{{ValidInTagName}+\}\}
FUNCTION = {FunctionCall}
% START_TAG = \{\{\#[A-Za-z0-9\w\s\.]+\}\}
% END_TAG   = \{\{/[A-Za-z0-9\w\s\.]+\}\}
% CHARACTER = .|\r\n|\n

CHARACTER = .|\r\n|\n
SPACE = \s
ASSIGNMENT = \=
QUOTATION = \'

TAG_CLOSE = \}\}

FUNCTION_TAG_START = \{\{
INTERPOLATION_TAG_START = \{\{\#
INTERPOLATION_TAG_CLOSE = \{\{\/

INTERPOLATION = {FUNCTION_TAG_START}{ValidInTagName}+{TAG_CLOSE}

Rules.

{SPACE}  : {token, {space, TokenLine, TokenChars}}.
{ASSIGNMENT} : {token, {assignment, TokenLine, TokenChars}}.
{QUOTATION} : {token, {quotation, TokenLine, TokenChars}}.

{ARG_PAIR} : {token, {arg_pair, TokenLine, TokenChars}}.
{INTERPOLATION} : {token, {interpolation, TokenLine, TokenChars}}.

{TAG_CLOSE} : {token, {tag_close, TokenLine, TokenChars}}.

{FUNCTION_TAG_START} : {token, {function_tag_start, TokenLine, TokenChars}}.
{INTERPOLATION_TAG_START} : {token, {interpolation_tag_start, TokenLine, TokenChars}}.
{INTERPOLATION_TAG_CLOSE} : {token, {interpolation_tag_close, TokenLine, TokenChars}}.

% {INTERPOLATION} : {token, {interpolation, TokenLine, TokenChars}}.
{CHARACTER} : {token, {char, TokenLine, TokenChars}}.
{FUNCTION} : {token, {function, TokenLine, TokenChars}}.

Erlang code.

