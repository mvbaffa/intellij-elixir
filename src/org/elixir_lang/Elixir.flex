package org.elixir_lang;

import com.intellij.lexer.FlexLexer;
import com.intellij.psi.TokenType;
import com.intellij.psi.tree.IElementType;
import org.elixir_lang.lexer.group.*;
import org.elixir_lang.psi.ElixirTypes;

%%

// public instead of package-local to make testing easier.
%public
%class ElixirFlexLexer
%implements FlexLexer
%unicode
%function advance
%type IElementType
%eof{  return;
%eof}

%{
  private org.elixir_lang.lexer.Stack stack = new org.elixir_lang.lexer.Stack();

  private void startQuote(CharSequence quotePromoterCharSequence) {
    String quotePromoter = quotePromoterCharSequence.toString();
    stack.push(quotePromoter, yystate());

    if (Base.isHeredocPromoter(quotePromoter)) {
      yybegin(GROUP_HEREDOC_START);
    } else {
      yybegin(GROUP);
    }
  }

  private IElementType fragmentType() {
    return stack.fragmentType();
  }

  private void handleInState(int nextLexicalState) {
    yypushback(yylength());
    yybegin(nextLexicalState);
  }

  private boolean isTerminator(CharSequence terminator) {
    return stack.terminator().equals(terminator.toString());
  }

  private boolean isInterpolating() {
    return stack.isInterpolating();
  }

  private boolean isInterpolatingSigil(CharSequence sigilName) {
    if (sigilName.length() != 1) {
      throw new IllegalArgumentException("sigil names can only be 1 character long");
    }

    return isInterpolatingSigil(sigilName.charAt(0));
  }

  private boolean isInterpolatingSigil(char sigilName) {
    return (sigilName >= 'a' && sigilName <= 'z');
  }

  private boolean isSigil() {
    return stack.isSigil();
  }

  private void nameSigil(CharSequence sigilName) {
    stack.nameSigil(sigilName.charAt(0));
  }

  private org.elixir_lang.lexer.StackFrame pop() {
    return stack.pop();
  }

  private org.elixir_lang.lexer.group.Quote promotedQuote(CharSequence promoterCharSequence) {
    // CharSequences don't look up correctly, so convert to String, which do.
    String promoter = promoterCharSequence.toString();
    org.elixir_lang.lexer.group.Quote quote = org.elixir_lang.lexer.group.Quote.fetch(promoter);

    return quote;
  }

  private IElementType promoterType() {
    return stack.promoterType();
  }

  private void setPromoter(CharSequence promoter) {
    stack.setPromoter(promoter.toString());
  }

  private IElementType sigilNameType() {
    return stack.sigilNameType();
  }

  // public for testing
  public void pushAndBegin(int lexicalState) {
    stack.push(yystate());
    yybegin(lexicalState);
  }

  private IElementType terminatorType() {
    return stack.terminatorType();
  }
%}

/*
 * Curly / Tuple
 */

OPENING_CURLY = "{"
CLOSING_CURLY = "}"

/*
 * Operator
 *
 * Note: before Atom because operator prefixed by {COLON} are valid Atoms
 */

FOUR_TOKEN_BITSTRING_OPERATOR = "<<>>"
FOUR_TOKEN_WHEN_OPERATOR = "when"
FOUR_TOKEN_OPERATOR = {FOUR_TOKEN_BITSTRING_OPERATOR} |
                      {FOUR_TOKEN_WHEN_OPERATOR}

THREE_TOKEN_AND_OPERATOR = "&&&" |
                           "and"
THREE_TOKEN_ARROW_OPERATOR = "<<<" |
                             "<<~" |
                             "<|>" |
                             "<~>" |
                             ">>>" |
                             "~>>"
THREE_TOKEN_COMPARISON_OPERATOR = "!==" |
                                  "==="
THREE_TOKEN_HAT_OPERATOR = "^^^"
THREE_TOKEN_MAP_OPERATOR = "%" {OPENING_CURLY} {CLOSING_CURLY}
THREE_TOKEN_OR_OPERATOR = "|||"
THREE_TOKEN_UNARY_OPERATOR = "not" |
                             "~~~"

THREE_TOKEN_OPERATOR = {THREE_TOKEN_AND_OPERATOR} |
                       {THREE_TOKEN_ARROW_OPERATOR} |
                       {THREE_TOKEN_COMPARISON_OPERATOR} |
                       {THREE_TOKEN_HAT_OPERATOR} |
                       {THREE_TOKEN_MAP_OPERATOR} |
                       {THREE_TOKEN_OR_OPERATOR} |
                       {THREE_TOKEN_UNARY_OPERATOR} |
                       "..."

TWO_TOKEN_AND_OPERATOR = "&&"
TWO_TOKEN_ARROW_OPERATOR = "<~" |
                           "|>" |
                           "~>"
TWO_TOKEN_ASSOCIATION_OPERATOR = "=>"
TWO_TOKEN_COMPARISON_OPERATOR = "!=" |
                                "==" |
                                "=~"
TWO_TOKEN_IN_MATCH_OPERATOR = "<-" |
                              "\\\\"
TWO_TOKEN_OR_OPERATOR = "or" |
                        "||"
TWO_TOKEN_RELATIONAL_OPERATOR = "<=" |
                                ">="
TWO_TOKEN_STAB_OPERATOR = "->"
TWO_TOKEN_TUPLE_OPERATOR = {OPENING_CURLY} {CLOSING_CURLY}
TWO_TOKEN_TWO_OPERATOR = "++" |
                         "--" |
                         "--" |
                         ".." |
                         "<>"
TWO_TOKEN_TYPE_OPERATOR = "::"

TWO_TOKEN_OPERATOR = {TWO_TOKEN_AND_OPERATOR} |
                     {TWO_TOKEN_ARROW_OPERATOR} |
                     {TWO_TOKEN_ASSOCIATION_OPERATOR} |
                     {TWO_TOKEN_COMPARISON_OPERATOR} |
                     {TWO_TOKEN_IN_MATCH_OPERATOR} |
                     {TWO_TOKEN_OR_OPERATOR} |
                     {TWO_TOKEN_RELATIONAL_OPERATOR} |
                     {TWO_TOKEN_STAB_OPERATOR} |
                     {TWO_TOKEN_TUPLE_OPERATOR} |
                     {TWO_TOKEN_TWO_OPERATOR} |
                     {TWO_TOKEN_TYPE_OPERATOR}

ONE_TOKEN_AT_OPERATOR = "@"
ONE_TOKEN_CAPTURE_OPERATOR = "&"
ONE_TOKEN_DOT_OPERATOR = "."
/* Dual because they have a dual role as unary operators and binary operators
   @see https://github.com/elixir-lang/elixir/blob/de39bbaca277002797e52ffbde617ace06233a2b/lib/elixir/src/elixir_tokenizer.erl#L31-L32 */
ONE_TOKEN_DUAL_OPERATOR = "+" |
                          "-"
ONE_TOKEN_IN_OPERATOR = "in"
ONE_TOKEN_MATCH_OPERATOR = "="
ONE_TOKEN_MULTIPLICATION_OPERATOR = "*" |
                                    "/"
ONE_TOKEN_PIPE_OPERATOR = "|"
ONE_TOKEN_RELATIONAL_OPERATOR = "<" |
                                ">"
ONE_TOKEN_STRUCT_OPERATOR = "%"
ONE_TOKEN_UNARY_OPERATOR = "!" |
                           "^"

ONE_TOKEN_OPERATOR = {ONE_TOKEN_AT_OPERATOR} |
                     {ONE_TOKEN_CAPTURE_OPERATOR} |
                     {ONE_TOKEN_DOT_OPERATOR} |
                     {ONE_TOKEN_DUAL_OPERATOR} |
                     {ONE_TOKEN_IN_OPERATOR} |
                     {ONE_TOKEN_MATCH_OPERATOR} |
                     {ONE_TOKEN_MULTIPLICATION_OPERATOR} |
                     {ONE_TOKEN_PIPE_OPERATOR} |
                     {ONE_TOKEN_RELATIONAL_OPERATOR} |
                     {ONE_TOKEN_STRUCT_OPERATOR} |
                     {ONE_TOKEN_UNARY_OPERATOR}

AND_OPERATOR = {THREE_TOKEN_AND_OPERATOR} |
               {TWO_TOKEN_AND_OPERATOR}
ARROW_OPERATOR = {THREE_TOKEN_ARROW_OPERATOR} |
                 {TWO_TOKEN_ARROW_OPERATOR}
ASSOCIATION_OPERATOR = {TWO_TOKEN_ASSOCIATION_OPERATOR}
AT_OPERATOR = {ONE_TOKEN_AT_OPERATOR}
BIT_STRING_OPERATOR = {FOUR_TOKEN_BITSTRING_OPERATOR}
CAPTURE_OPERATOR = {ONE_TOKEN_CAPTURE_OPERATOR}
DOT_OPERATOR = {ONE_TOKEN_DOT_OPERATOR}
// Dual because they have a dual role as unary operators and binary operators
DUAL_OPERATOR = {ONE_TOKEN_DUAL_OPERATOR}
COMPARISON_OPERATOR = {THREE_TOKEN_COMPARISON_OPERATOR} |
                      {TWO_TOKEN_COMPARISON_OPERATOR}
HAT_OPERATOR = {THREE_TOKEN_HAT_OPERATOR}
IN_MATCH_OPERATOR = {TWO_TOKEN_IN_MATCH_OPERATOR}
IN_OPERATOR = {ONE_TOKEN_IN_OPERATOR}
MAP_OPERATOR = {THREE_TOKEN_MAP_OPERATOR}
MATCH_OPERATOR = {ONE_TOKEN_MATCH_OPERATOR}
MULTIPLICATION_OPERATOR = {ONE_TOKEN_MULTIPLICATION_OPERATOR}
OR_OPERATOR = {THREE_TOKEN_OR_OPERATOR} |
              {TWO_TOKEN_OR_OPERATOR}
PIPE_OPERATOR = {ONE_TOKEN_PIPE_OPERATOR}
RELATIONAL_OPERATOR = {TWO_TOKEN_RELATIONAL_OPERATOR} |
                      {ONE_TOKEN_RELATIONAL_OPERATOR}
STAB_OPERATOR = {TWO_TOKEN_STAB_OPERATOR}
STRUCT_OPERATOR = {ONE_TOKEN_STRUCT_OPERATOR}
TUPLE_OPERATOR = {TWO_TOKEN_TUPLE_OPERATOR}
TWO_OPERATOR = {TWO_TOKEN_TWO_OPERATOR}
TYPE_OPERATOR = {TWO_TOKEN_TYPE_OPERATOR}
UNARY_OPERATOR = {THREE_TOKEN_UNARY_OPERATOR} |
                 {ONE_TOKEN_UNARY_OPERATOR}
WHEN_OPERATOR = {FOUR_TOKEN_WHEN_OPERATOR}

// OPERATOR is from longest to shortest so longest match wins
OPERATOR = {FOUR_TOKEN_OPERATOR} |
           {THREE_TOKEN_OPERATOR} |
           {TWO_TOKEN_OPERATOR} |
           {ONE_TOKEN_OPERATOR}

/*
 * Atom
 */

ATOM_END = [?!]
ATOM_MIDDLE = [0-9a-zA-Z@_]
ATOM_START = [a-zA-Z_]
COLON = :

/*
 * Containers
 */

COMMA = ","

/*
 * Digits
 */

HEXADECIMAL_DIGIT = [A-Fa-f0-9]

/*
 * EOE (End of Expression)
 */

SEMICOLON = ";"

/*
 * EOL
 */

EOL = \n|\r\n

/*
 * Escape Sequences
 */

ESCAPE = "\\"

ESCAPED_CHARACTER_TOKEN = {ESCAPE} .
ESCAPED_CHARACTER_CODE = {ESCAPE} "x{" {HEXADECIMAL_DIGIT}{1,6} "}" |
                         {ESCAPE} "x" {HEXADECIMAL_DIGIT}{1,2}
ESCAPED_EOL = {ESCAPE} {EOL}

VALID_ESCAPE_SEQUENCE = {ESCAPED_CHARACTER_CODE} |
                        {ESCAPED_CHARACTER_TOKEN} |
                        {ESCAPED_EOL}

/*
 * Char tokens
 */

CHAR_TOKENIZER = "?"

/*
 * White Space
 */

HORIZONTAL_SPACE = [ \t]
VERTICAL_SPACE = [\n\r]
SPACE = {HORIZONTAL_SPACE} | {VERTICAL_SPACE}
WHITE_SPACE=[\ \t\f]

/*
 *  Comments
 */

COMMENT = "#" [^\r\n]*

/*
 *
 *   Whole Numbers
 *
 */

VALID_DECIMAL_DIGITS = [0-9]+
INVALID_DECIMAL_DIGITS = [A-Za-z]+
DECIMAL_SEPARATOR = "_"

/*
 * Non-Base-10
 */

BASE_WHOLE_NUMBER_PREFIX = "0"
BASE_WHOLE_NUMBER_BASE = [A-Za-z]

BINARY_WHOLE_NUMBER_BASE = "b"
OBSOLETE_BINARY_WHOLE_NUMBER_BASE = "B"
VALID_BINARY_DIGITS = [01]+
INVALID_BINARY_DIGITS = [A-Za-z2-9]+

HEXADECIMAL_WHOLE_NUMBER_BASE = "x"
OBSOLETE_HEXADECIMAL_WHOLE_NUMBER_BASE = "X"
VALID_HEXADECIMAL_DIGITS = {HEXADECIMAL_DIGIT}+
INVALID_HEXADECIMAL_DIGITS = [G-Zg-z]+

OCTAL_WHOLE_NUMBER_BASE = "o"
VALID_OCTAL_DIGITS = [0-7]+
INVALID_OCTAL_DIGITS = [A-Za-z8-9]+

INVALID_UNKNOWN_BASE_DIGITS = [A-Za-z0-9]+

/*
 * Identifiers
 */

IDENTIFIER_END = [?!]
IDENTIFIER_MIDDLE = [0-9a-zA-Z_]
IDENTIFIER_START = [a-z_]
IDENTIFIER_HEAD = {IDENTIFIER_START}
IDENTIFIER_TAIL = {IDENTIFIER_MIDDLE}* {IDENTIFIER_END}?
IDENTIFIER = ({IDENTIFIER_HEAD} {IDENTIFIER_TAIL}  | "...")

/*
 * Aliases
 */

ALIAS_HEAD = [A-Z]
ALIAS = {ALIAS_HEAD} {IDENTIFIER_TAIL}

/*
 * Parent
 */

INTERPOLATION_START = "#{"
INTERPOLATION_END = "}"

/*
 * Floats
 */

DECIMAL_MARK = "."
EXPONENT_MARK = [Ee]

/*
 * List
 */

CLOSING_BRACKET = "]"
OPENING_BRACKET = "["

/*
 * Parentheses
 */

CLOSING_PARENTHESIS = ")"
OPENING_PARENTHESIS = "("

/*
 *
 *  Quotes
 *
 */

CHAR_LIST_PROMOTER = "'"
CHAR_LIST_TERMINATOR = "'"

STRING_PROMOTER = "\""
STRING_TERMINATOR = "\""

QUOTE_PROMOTER = {CHAR_LIST_PROMOTER} | {STRING_PROMOTER}
QUOTE_TERMINATOR = {CHAR_LIST_TERMINATOR} | {STRING_TERMINATOR}

/*
 * Quote Heredocs
 */

CHAR_LIST_HEREDOC_PROMOTER = {CHAR_LIST_PROMOTER}{3}
CHAR_LIST_HEREDOC_TERMINATOR = {CHAR_LIST_TERMINATOR}{3}

STRING_HEREDOC_PROMOTER = {STRING_PROMOTER}{3}
STRING_HEREDOC_TERMINATOR = {STRING_TERMINATOR}{3}

QUOTE_HEREDOC_PROMOTER = {CHAR_LIST_HEREDOC_PROMOTER} | {STRING_HEREDOC_PROMOTER}
QUOTE_HEREDOC_TERMINATOR = {CHAR_LIST_HEREDOC_TERMINATOR} | {STRING_HEREDOC_TERMINATOR}

/*
 * Regular Keywords
 */

END = "end"
FALSE = "false"
FN = "fn"
NIL = "nil"
TRUE = "true"

/*
 *
 *  Sigils
 *
 */

TILDE = "~"
SIGIL_MODIFIER = [a-z]
SIGIL_NAME = [A-Za-z]

/*
 * Sigil quotes
 *
 * @see https://github.com/elixir-lang/elixir/blob/a4a23b9a937cb22b5c1a2487c02289817b991d8f/lib/elixir/src/elixir.hrl#L59-L60
 */

SIGIL_BRACES_PROMOTER = "{"
SIGIL_BRACES_TERMINATOR = "}"
SIGIL_BRACKETS_PROMOTER = "["
SIGIL_BRACKETS_TERMINATOR = "]"
SIGIL_CHEVRONS_PROMOTER = "<"
SIGIL_CHEVRONS_TERMINATOR = ">"
SIGIL_DOUBLE_QUOTES_PROMOTER = "\""
SIGIL_DOUBLE_QUOTES_TERMINATOR = "\""
SIGIL_FORWARD_SLASH_PROMOTER = "/"
SIGIL_FORWARD_SLASH_TERMINATOR = "/"
SIGIL_PARENTHESES_PROMOTER = "("
SIGIL_PARENTHESES_TERMINATOR = ")"
SIGIL_PIPE_PROMOTER = "|"
SIGIL_PIPE_TERMINATOR = "|"
SIGIL_SINGLE_QUOTES_PROMOTER = "'"
SIGIL_SINGLE_QUOTES_TERMINATOR = "'"

SIGIL_PROMOTER = {SIGIL_BRACES_PROMOTER} |
                 {SIGIL_BRACKETS_PROMOTER} |
                 {SIGIL_CHEVRONS_PROMOTER} |
                 {SIGIL_DOUBLE_QUOTES_PROMOTER} |
                 {SIGIL_FORWARD_SLASH_PROMOTER} |
                 {SIGIL_PARENTHESES_PROMOTER} |
                 {SIGIL_PIPE_PROMOTER} |
                 {SIGIL_SINGLE_QUOTES_PROMOTER}


SIGIL_TERMINATOR = {SIGIL_BRACES_TERMINATOR} |
                   {SIGIL_BRACKETS_TERMINATOR} |
                   {SIGIL_CHEVRONS_TERMINATOR} |
                   {SIGIL_DOUBLE_QUOTES_TERMINATOR} |
                   {SIGIL_FORWARD_SLASH_TERMINATOR} |
                   {SIGIL_PARENTHESES_TERMINATOR} |
                   {SIGIL_PIPE_TERMINATOR} |
                   {SIGIL_SINGLE_QUOTES_TERMINATOR}

/*
 * Sigil heredocs
 */

SIGIL_HEREDOC_PROMOTER = ({SIGIL_DOUBLE_QUOTES_PROMOTER}|{SIGIL_SINGLE_QUOTES_PROMOTER}){3}
SIGIL_HEREDOC_TERMINATOR = ({SIGIL_DOUBLE_QUOTES_TERMINATOR}|{SIGIL_SINGLE_QUOTES_TERMINATOR}){3}

/*
 * Groups
 */

GROUP_TERMINATOR = {QUOTE_TERMINATOR}|{SIGIL_TERMINATOR}
GROUP_HEREDOC_TERMINATOR = {QUOTE_HEREDOC_TERMINATOR}|{SIGIL_HEREDOC_TERMINATOR}

/*
 *  States - Ordered lexigraphically
 */

%state ATOM_BODY
%state ATOM_START
%state BASE_WHOLE_NUMBER_BASE
%state BINARY_WHOLE_NUMBER
%state CALL_MAYBE
%state CALL_OR_KEYWORD_PAIR_MAYBE
%state CHAR_TOKENIZATION
%state DECIMAL_EXPONENT
%state DECIMAL_EXPONENT_SIGN
%state DECIMAL_FRACTION
%state DECIMAL_WHOLE_NUMBER
%state DOT_OPERATION
%state DUAL_OPERATION
%state ESCAPE_IN_LITERAL_GROUP
%state ESCAPE_SEQUENCE
%state EXTENDED_HEXADECIMAL_ESCAPE_SEQUENCE
%state GROUP
%state GROUP_HEREDOC_END
%state GROUP_HEREDOC_LINE_BODY
%state GROUP_HEREDOC_LINE_START
%state GROUP_HEREDOC_START
%state HEXADECIMAL_ESCAPE_SEQUENCE
%state HEXADECIMAL_WHOLE_NUMBER
%state INTERPOLATION
%state KEYWORD_PAIR_MAYBE
%state NAMED_SIGIL
%state OCTAL_WHOLE_NUMBER
%state SIGIL
%state SIGIL_MODIFIERS
%state UNKNOWN_BASE_WHOLE_NUMBER

%%

/* <YYINITIAL> is first even though it isn't lexicographically first because it is the first state.
   Rules that aren't dependent on detecting the end of INTERPOLATION can be shared between <YYINITIAL> and
   <INTERPOLATION> */
<YYINITIAL, INTERPOLATION> {
  {AND_OPERATOR}                             { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.AND_OPERATOR; }
  {ARROW_OPERATOR}                           { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.ARROW_OPERATOR; }
  {ASSOCIATION_OPERATOR}                     { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.ASSOCIATION_OPERATOR; }
  {ALIAS}                                    { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.ALIAS_TOKEN; }
  {AT_OPERATOR}                              { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.AT_OPERATOR; }
  {BASE_WHOLE_NUMBER_PREFIX} / {BASE_WHOLE_NUMBER_BASE} { pushAndBegin(BASE_WHOLE_NUMBER_BASE);
                                                          return ElixirTypes.BASE_WHOLE_NUMBER_PREFIX; }
  {BIT_STRING_OPERATOR}                      { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.BIT_STRING_OPERATOR; }
  {CAPTURE_OPERATOR}                         { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.CAPTURE_OPERATOR; }
  {CLOSING_BRACKET}                          { return ElixirTypes.CLOSING_BRACKET; }
  {CLOSING_PARENTHESIS}                      { return ElixirTypes.CLOSING_PARENTHESIS; }
  {EOL}                                      { return ElixirTypes.EOL; }
  {END}                                      { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.END; }
  {ESCAPED_EOL}|{WHITE_SPACE}+       { return TokenType.WHITE_SPACE; }
  {CHAR_TOKENIZER}                                      { pushAndBegin(CHAR_TOKENIZATION);
                                                          return ElixirTypes.CHAR_TOKENIZER; }
  /* So that that atom of comparison operator consumes all 3 ':' instead of {TYPE_OPERATOR} consuming '::'
     and ':' being leftover */
  {COLON} / {TYPE_OPERATOR}                  { pushAndBegin(ATOM_START);
                                               return ElixirTypes.COLON; }
  {COLON} / {SPACE}                          { return ElixirTypes.COLON; }
  // Must be after `{COLON} / {TYPE_OPERATOR}`, so that 3 ':' are consumed before 1.
  {TYPE_OPERATOR}                            { return ElixirTypes.TYPE_OPERATOR; }
  // Must be after {TYPE_OPERATOR}, so that 1 ':' is consumed after 2
  {COLON}                                    { pushAndBegin(ATOM_START);
                                               return ElixirTypes.COLON; }
  {COMMA}                                    { return ElixirTypes.COMMA; }
  {COMMENT}                                  { return ElixirTypes.COMMENT; }
  {COMPARISON_OPERATOR}                      { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.COMPARISON_OPERATOR; }
  // DOT_OPERATOR is not a valid keywordKey, so no need to go to KEYWORD_PAIR_MAYBE
  {DOT_OPERATOR}                             { pushAndBegin(DOT_OPERATION);
                                               return ElixirTypes.DOT_OPERATOR; }
  {DUAL_OPERATOR}                            { pushAndBegin(DUAL_OPERATION);
                                               return ElixirTypes.DUAL_OPERATOR; }
  {FALSE}                                    { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.FALSE; }
  {FN}                                       { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.FN; }
  {HAT_OPERATOR}                             { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.HAT_OPERATOR; }
  {OPENING_BRACKET}                          { return ElixirTypes.OPENING_BRACKET; }
  {OPENING_PARENTHESIS}                      { return ElixirTypes.OPENING_PARENTHESIS; }
  // Must be before {IDENTIFIER} as "in" would be parsed as an identifier since it's a lowercase alphanumeric.
  {IN_OPERATOR}                              { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.IN_OPERATOR; }
  // Must be before {IDENTIFIER} as "nil" would be parsed as an identifier since it's a lowercase alphanumeric.
  {NIL}                                      { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.NIL; }
  // Must be before {IDENTIFIER} as "or" would be parsed as an identifier since it's a lowercase alphanumeric.
  {OR_OPERATOR}                              { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.OR_OPERATOR; }
  // Must be before {IDENTIFIER} as "true" would be parsed as an identifier since it's a lowercase alphanumeric.
  {TRUE}                                     { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.TRUE; }
  // Must be before {IDENTIFIER} as "not" would be parsed as an identifier since it's a lowercase alphanumeric.
  {UNARY_OPERATOR}                           { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.UNARY_OPERATOR; }
  // Must be before {IDENTIFIER} as "when" would be parsed as an identifier since it's a lowercase alphanumeric.
  {WHEN_OPERATOR}                            { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.WHEN_OPERATOR; }
  {IDENTIFIER}                               { pushAndBegin(CALL_OR_KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.IDENTIFIER; }
  {IN_MATCH_OPERATOR}                        { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.IN_MATCH_OPERATOR; }
  {MAP_OPERATOR}                             { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.MAP_OPERATOR; }
  {MATCH_OPERATOR}                           { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.MATCH_OPERATOR; }
  {MULTIPLICATION_OPERATOR}                  { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.MULTIPLICATION_OPERATOR; }
  {PIPE_OPERATOR}                            { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.PIPE_OPERATOR; }
  {RELATIONAL_OPERATOR}                      { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.RELATIONAL_OPERATOR; }
  {SEMICOLON}                                { return ElixirTypes.SEMICOLON; }
  {STAB_OPERATOR}                            { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.STAB_OPERATOR; }
  {STRUCT_OPERATOR}                          { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.STRUCT_OPERATOR; }
  {TILDE}                                    { pushAndBegin(SIGIL);
                                               return ElixirTypes.TILDE; }
  {TUPLE_OPERATOR}                           { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.TUPLE_OPERATOR; }
  {TWO_OPERATOR}                             { pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               return ElixirTypes.TWO_OPERATOR; }
  {VALID_DECIMAL_DIGITS}                     { pushAndBegin(DECIMAL_WHOLE_NUMBER);
                                               return ElixirTypes.VALID_DECIMAL_DIGITS; }
  {QUOTE_HEREDOC_PROMOTER}                   { startQuote(yytext());
                                               return promoterType(); }
  /* MUST be after {QUOTE_HEREDOC_PROMOTER} for <BODY, INTERPOLATION> as {QUOTE_HEREDOC_PROMOTER} is prefixed by
     {QUOTE_PROMOTER} */
  {QUOTE_PROMOTER}                           { /* return to KEYWORD_PAIR_MAYBE so that COLON after quote can be parsed
                                                  as KEYWORD_PAIR_COLON to differentiate between valid `<quote><colon>`
                                                  and invalid `<quote><space><colon>`. */
                                               pushAndBegin(KEYWORD_PAIR_MAYBE);
                                               startQuote(yytext());
                                               return promoterType(); }
}

/*
 *  Lexical rules - Ordered alphabetically by state name except when the order of the internal rules need to be
 *  maintained to ensure precedence.
 */

<ATOM_BODY> {
  {ATOM_END}     { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                   yybegin(stackFrame.getLastLexicalState());
                   return ElixirTypes.ATOM_FRAGMENT; }
  {ATOM_MIDDLE}+ { return ElixirTypes.ATOM_FRAGMENT; }
  // any other character ends the atom
  {EOL}|.        { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                   handleInState(stackFrame.getLastLexicalState()); }
}

/// Must be after {QUOTE_PROMOTER} for <ATOM_START> so that
<ATOM_START> {
  {ATOM_START}     { yybegin(ATOM_BODY);
                     return ElixirTypes.ATOM_FRAGMENT; }
  {QUOTE_PROMOTER} { /* At the end of the quote, return the state (YYINITIAL or INTERPOLATION) before ATOM_START as
                        anything after the closing quote should be handle by the state prior to ATOM_START.  Without
                        this, EOL and WHITESPACE won't be handled correctly */
                     org.elixir_lang.lexer.StackFrame stackFrame = pop();
                     yybegin(stackFrame.getLastLexicalState());
                     startQuote(yytext());
                     return promoterType(); }
  {OPERATOR}       { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                     yybegin(stackFrame.getLastLexicalState());
                     return ElixirTypes.ATOM_FRAGMENT; }
  {EOL}            { return TokenType.BAD_CHARACTER; }
}

<BASE_WHOLE_NUMBER_BASE> {
  {BINARY_WHOLE_NUMBER_BASE}               { yybegin(BINARY_WHOLE_NUMBER);
                                             return ElixirTypes.BINARY_WHOLE_NUMBER_BASE; }
  {HEXADECIMAL_WHOLE_NUMBER_BASE}          { yybegin(HEXADECIMAL_WHOLE_NUMBER);
                                             return ElixirTypes.HEXADECIMAL_WHOLE_NUMBER_BASE; }
  {OBSOLETE_BINARY_WHOLE_NUMBER_BASE}      { yybegin(BINARY_WHOLE_NUMBER);
                                             return ElixirTypes.OBSOLETE_BINARY_WHOLE_NUMBER_BASE; }
  {OBSOLETE_HEXADECIMAL_WHOLE_NUMBER_BASE} { yybegin(HEXADECIMAL_WHOLE_NUMBER);
                                             return ElixirTypes.OBSOLETE_HEXADECIMAL_WHOLE_NUMBER_BASE; }
  {OCTAL_WHOLE_NUMBER_BASE}                { yybegin(OCTAL_WHOLE_NUMBER);
                                             return ElixirTypes.OCTAL_WHOLE_NUMBER_BASE; }
  // Must be after any specific integer bases
  {BASE_WHOLE_NUMBER_BASE}                 { yybegin(UNKNOWN_BASE_WHOLE_NUMBER);
                                             return ElixirTypes.UNKNOWN_WHOLE_NUMBER_BASE; }
}

<BINARY_WHOLE_NUMBER> {
  {INVALID_BINARY_DIGITS} { return ElixirTypes.INVALID_BINARY_DIGITS; }
  {VALID_BINARY_DIGITS}   { return ElixirTypes.VALID_BINARY_DIGITS; }
  {EOL}|.                 { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                            handleInState(stackFrame.getLastLexicalState()); }
}

<CALL_MAYBE, CALL_OR_KEYWORD_PAIR_MAYBE> {
  {OPENING_BRACKET}|{OPENING_PARENTHESIS} { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                                            handleInState(stackFrame.getLastLexicalState());
                                            // zero-width token
                                            return ElixirTypes.CALL; }
}

<CALL_MAYBE> {
  {EOL}|.                                 { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                                            handleInState(stackFrame.getLastLexicalState()); }
}

<CALL_OR_KEYWORD_PAIR_MAYBE> {
  {EOL}|.                                 { handleInState(KEYWORD_PAIR_MAYBE); }
}

<CHAR_TOKENIZATION> {
  {ESCAPE} { yybegin(ESCAPE_SEQUENCE);
             return ElixirTypes.ESCAPE; }
  {EOL}|.  { org.elixir_lang.lexer.StackFrame stackFrame = pop();
             yybegin(stackFrame.getLastLexicalState());
             return ElixirTypes.CHAR_LIST_FRAGMENT; }
}

<DECIMAL_EXPONENT_SIGN> {
  {DUAL_OPERATOR} { yybegin(DECIMAL_EXPONENT);
                    return ElixirTypes.DUAL_OPERATOR; }
  {EOL}|.         { handleInState(DECIMAL_EXPONENT); }
}

<DECIMAL_FRACTION> {
  {EXPONENT_MARK} { yybegin(DECIMAL_EXPONENT_SIGN);
                    return ElixirTypes.EXPONENT_MARK; }
}

<DECIMAL_WHOLE_NUMBER> {
  /*
   Error handling with {INVALID_DECIMAL_DIGITS} and {DECIMAL_SEPARATOR} can only occur after at least one valid decimal
   digit after the decimal mark because {INVALID_DECIMAL_DIGITS} and {DECIMAL_SEPARATOR} will be parsed as an
   identifier immediately after `.`

   ```
   iex> Code.string_to_quoted("1._")
   {:ok, {{:., [line: 1], [1, :_]}, [line: 1], []}}
   iex> Code.string_to_quoted("1.a")
   {:ok, {{:., [line: 1], [1, :a]}, [line: 1], []}}
   ```
  */
  {DECIMAL_MARK} / {VALID_DECIMAL_DIGITS} { yybegin(DECIMAL_FRACTION);
                                            return ElixirTypes.DECIMAL_MARK; }
}

<DECIMAL_EXPONENT,
 DECIMAL_FRACTION,
 DECIMAL_WHOLE_NUMBER> {
  {DECIMAL_SEPARATOR}      { return ElixirTypes.DECIMAL_SEPARATOR; }
  {INVALID_DECIMAL_DIGITS} { return ElixirTypes.INVALID_DECIMAL_DIGITS; }
  {VALID_DECIMAL_DIGITS}   { return ElixirTypes.VALID_DECIMAL_DIGITS; }
  {EOL}|.                  { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                             handleInState(stackFrame.getLastLexicalState()); }
}

<DOT_OPERATION> {
  {AND_OPERATOR}               { yybegin(CALL_MAYBE);
                                 return ElixirTypes.AND_OPERATOR; }
  {ARROW_OPERATOR}             { yybegin(CALL_MAYBE);
                                 return ElixirTypes.ARROW_OPERATOR; }
  {AT_OPERATOR}                { yybegin(CALL_MAYBE);
                                 return ElixirTypes.AT_OPERATOR; }
  {CAPTURE_OPERATOR}           { yybegin(CALL_MAYBE);
                                return ElixirTypes.CAPTURE_OPERATOR; }
  {COMPARISON_OPERATOR}        { yybegin(CALL_MAYBE);
                                 return ElixirTypes.COMPARISON_OPERATOR; }
  {DUAL_OPERATOR}              { yybegin(CALL_MAYBE);
                                 return ElixirTypes.DUAL_OPERATOR; }
  {HAT_OPERATOR}               { yybegin(CALL_MAYBE);
                                 return ElixirTypes.HAT_OPERATOR; }
  {IN_MATCH_OPERATOR}          { yybegin(CALL_MAYBE);
                                 return ElixirTypes.IN_MATCH_OPERATOR; }
  {IN_OPERATOR}                { yybegin(CALL_MAYBE);
                                 return ElixirTypes.IN_OPERATOR; }
  {MATCH_OPERATOR}             { yybegin(CALL_MAYBE);
                                 return ElixirTypes.MATCH_OPERATOR; }
  {MULTIPLICATION_OPERATOR}    { yybegin(CALL_MAYBE);
                                 return ElixirTypes.MULTIPLICATION_OPERATOR; }
  {OR_OPERATOR}                { yybegin(CALL_MAYBE);
                                 return ElixirTypes.OR_OPERATOR; }
  {PIPE_OPERATOR}              { yybegin(CALL_MAYBE);
                                 return ElixirTypes.PIPE_OPERATOR; }
  {RELATIONAL_OPERATOR}        { yybegin(CALL_MAYBE);
                                 return ElixirTypes.RELATIONAL_OPERATOR; }
  {STAB_OPERATOR}              { yybegin(CALL_MAYBE);
                                 return ElixirTypes.STAB_OPERATOR; }
  {STRUCT_OPERATOR}            { yybegin(CALL_MAYBE);
                                 return ElixirTypes.STRUCT_OPERATOR; }
  {TWO_OPERATOR}               { yybegin(CALL_MAYBE);
                                 return ElixirTypes.TWO_OPERATOR; }
  {UNARY_OPERATOR}             { yybegin(CALL_MAYBE);
                                 return ElixirTypes.UNARY_OPERATOR; }
  {WHEN_OPERATOR}              { yybegin(CALL_MAYBE);
                                 return ElixirTypes.WHEN_OPERATOR; }

  /*
   * Emulates strip_space in elixir_tokenizer.erl
   */

  {ESCAPED_EOL}|{WHITE_SPACE}+ { return TokenType.WHITE_SPACE; }
  {EOL}                        { return ElixirTypes.EOL; }

  /* Be better than strip_space and handle_dot and ignore comments so that IDENTIFIER and operators are parsed the same
     after dots.

     @see https://groups.google.com/forum/#!topic/elixir-lang-core/nnI4oUB-63U
   */
  {COMMENT}                    { return ElixirTypes.COMMENT; }

  .                            { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                                 handleInState(stackFrame.getLastLexicalState()); }
}

<DUAL_OPERATION> {
  {WHITE_SPACE}+ { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                   yybegin(stackFrame.getLastLexicalState());
                   return ElixirTypes.SIGNIFICANT_WHITE_SPACE; }
  {EOL}|.        { handleInState(KEYWORD_PAIR_MAYBE); }
}

<ESCAPE_IN_LITERAL_GROUP> {
  {EOL}|. {
            yybegin(GROUP);
            return fragmentType();
          }
}

<ESCAPE_SEQUENCE> {
  {EOL}                           { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                                    yybegin(stackFrame.getLastLexicalState());
                                    return ElixirTypes.EOL; }
  {HEXADECIMAL_WHOLE_NUMBER_BASE} { yybegin(HEXADECIMAL_ESCAPE_SEQUENCE);
                                    return ElixirTypes.HEXADECIMAL_WHOLE_NUMBER_BASE; }
  .                               { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                                    yybegin(stackFrame.getLastLexicalState());
                                    return ElixirTypes.ESCAPED_CHARACTER_TOKEN; }
}

<EXTENDED_HEXADECIMAL_ESCAPE_SEQUENCE> {
  {CLOSING_CURLY}          { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                             yybegin(stackFrame.getLastLexicalState());
                             return ElixirTypes.CLOSING_CURLY; }
  {HEXADECIMAL_DIGIT}{1,6} { return ElixirTypes.VALID_HEXADECIMAL_DIGITS; }
}

<GROUP,
 GROUP_HEREDOC_LINE_BODY> {
  {INTERPOLATION_START} {
                          if (isInterpolating()) {
                           pushAndBegin(INTERPOLATION);
                           return ElixirTypes.INTERPOLATION_START;
                          } else {
                           return fragmentType();
                          }
                        }
}

// Rules in GROUP, but not GROUP_HEREDOC_LINE_BODY
<GROUP> {
  {ESCAPE}           {
                       if (isInterpolating()) {
                         pushAndBegin(ESCAPE_SEQUENCE);
                         return ElixirTypes.ESCAPE;
                       } else {
                         yybegin(ESCAPE_IN_LITERAL_GROUP);
                         return fragmentType();
                       }
                     }
  {GROUP_TERMINATOR} {
                       if (isTerminator(yytext())) {
                         if (isSigil()) {
                           yybegin(SIGIL_MODIFIERS);
                           return terminatorType();
                         } else {
                           org.elixir_lang.lexer.StackFrame stackFrame = pop();
                           yybegin(stackFrame.getLastLexicalState());
                           return stackFrame.terminatorType();
                         }
                       } else {
                         return fragmentType();
                       }
                     }
  {EOL}|.            { return fragmentType(); }

}

<GROUP_HEREDOC_END> {
    {GROUP_HEREDOC_TERMINATOR} {
                                   if (isTerminator(yytext())) {
                                      if (isSigil()) {
                                        yybegin(SIGIL_MODIFIERS);
                                        return terminatorType();
                                      } else {
                                        org.elixir_lang.lexer.StackFrame stackFrame = pop();
                                        yybegin(stackFrame.getLastLexicalState());
                                        return stackFrame.terminatorType();
                                      }
                                   } else {
                                      handleInState(GROUP_HEREDOC_LINE_BODY);
                                   }
                               }
}

// Rules in GROUP_HEREDOC_LINE_BODY, but not GROUP
<GROUP_HEREDOC_LINE_BODY> {
  {ESCAPE} {
             if (isInterpolating()) {
               pushAndBegin(ESCAPE_SEQUENCE);
               return ElixirTypes.ESCAPE;
             } else {
               return fragmentType();
             }
           }
  {EOL} {
          yybegin(GROUP_HEREDOC_LINE_START);
          return ElixirTypes.EOL;
        }
  .     { return fragmentType(); }
}

<GROUP_HEREDOC_LINE_START> {
  {WHITE_SPACE}+ / {GROUP_HEREDOC_TERMINATOR} {
                                                  yybegin(GROUP_HEREDOC_END);
                                                  return ElixirTypes.HEREDOC_PREFIX_WHITE_SPACE;
                                              }
  {WHITE_SPACE}+                              {
                                                yybegin(GROUP_HEREDOC_LINE_BODY);
                                                return ElixirTypes.HEREDOC_LINE_WHITE_SPACE_TOKEN;
                                              }
  {GROUP_HEREDOC_TERMINATOR}                  { handleInState(GROUP_HEREDOC_END); }
  {EOL}|.                                     { handleInState(GROUP_HEREDOC_LINE_BODY); }
}

<GROUP_HEREDOC_START> {
  // parse immediate terminator as a terminator and let parser handle errors for missing EOL
  {GROUP_HEREDOC_TERMINATOR} {
                               // Similar to GROUP_HEREDOC_END's GROUP_HEREDOC_TERMINATOR rule, but...
                               if (isTerminator(yytext())) {
                                 if (isSigil()) {
                                   yybegin(SIGIL_MODIFIERS);
                                   return terminatorType();
                                 } else {
                                   org.elixir_lang.lexer.StackFrame stackFrame = pop();
                                   yybegin(stackFrame.getLastLexicalState());
                                   return stackFrame.terminatorType();
                                 }
                               } else {
                                 /* ...returns BAD_CHARACTER instead of going to GROUP_HEREDOC_LINE_BODY when the wrong
                                    type of terminator */
                                 return TokenType.BAD_CHARACTER;
                               }
                             }
  {EOL}                      { yybegin(GROUP_HEREDOC_LINE_START);
                               return ElixirTypes.EOL; }
}

<HEXADECIMAL_ESCAPE_SEQUENCE> {
  {OPENING_CURLY}          { yybegin(EXTENDED_HEXADECIMAL_ESCAPE_SEQUENCE);
                             return ElixirTypes.OPENING_CURLY; }
  {HEXADECIMAL_DIGIT}{1,2} { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                             yybegin(stackFrame.getLastLexicalState());
                             return ElixirTypes.VALID_HEXADECIMAL_DIGITS; }
  {EOL}|.                  { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                             handleInState(stackFrame.getLastLexicalState()); }
}

<HEXADECIMAL_WHOLE_NUMBER> {
  {INVALID_HEXADECIMAL_DIGITS} { return ElixirTypes.INVALID_HEXADECIMAL_DIGITS; }
  {VALID_HEXADECIMAL_DIGITS}   { return ElixirTypes.VALID_HEXADECIMAL_DIGITS; }
  {EOL}|.                      { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                                 handleInState(stackFrame.getLastLexicalState()); }
}

/* Only rules for <INTERPOLATON>, but not <YYINITIAL> go here.
   @note must be after <YYINITIAL, INTERPOLATION> so that BAD_CHARACTER doesn't match a single ' ' instead of
     {WHITE_SPACE}+. */
<INTERPOLATION> {
  {INTERPOLATION_END}         { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                                yybegin(stackFrame.getLastLexicalState());
                                return ElixirTypes.INTERPOLATION_END; }
}

<KEYWORD_PAIR_MAYBE> {
  {COLON} / {SPACE}         { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                              yybegin(stackFrame.getLastLexicalState());
                              return ElixirTypes.KEYWORD_PAIR_COLON; }
  {EOL}|.                   { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                              handleInState(stackFrame.getLastLexicalState()); }
}

<NAMED_SIGIL> {
  {SIGIL_HEREDOC_PROMOTER} { setPromoter(yytext());
                             yybegin(GROUP_HEREDOC_START);
                             return promoterType(); }
  {SIGIL_PROMOTER}         { setPromoter(yytext());
                             yybegin(GROUP);
                             return promoterType(); }
}

<OCTAL_WHOLE_NUMBER> {
  {INVALID_OCTAL_DIGITS} { return ElixirTypes.INVALID_OCTAL_DIGITS; }
  {VALID_OCTAL_DIGITS}   { return ElixirTypes.VALID_OCTAL_DIGITS; }
  {EOL}|.                { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                           handleInState(stackFrame.getLastLexicalState()); }
}

<SIGIL> {
  {SIGIL_NAME}               { nameSigil(yytext());
                               yybegin(NAMED_SIGIL);
                               return sigilNameType(); }
  {EOL}                      { return TokenType.BAD_CHARACTER; }
}

<SIGIL_MODIFIERS> {
  {SIGIL_MODIFIER} { return ElixirTypes.SIGIL_MODIFIER; }
  {EOL}|.          { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                     handleInState(stackFrame.getLastLexicalState()); }
}

<UNKNOWN_BASE_WHOLE_NUMBER> {
  {INVALID_UNKNOWN_BASE_DIGITS} { return ElixirTypes.INVALID_UNKNOWN_BASE_DIGITS; }
  {EOL}|.                       { org.elixir_lang.lexer.StackFrame stackFrame = pop();
                                  handleInState(stackFrame.getLastLexicalState()); }
}

// MUST go last so that . mapping to BAD_CHARACTER is the rule of last resort for the listed states
<ATOM_START, GROUP_HEREDOC_START, INTERPOLATION, NAMED_SIGIL, SIGIL, YYINITIAL> {
  . { return TokenType.BAD_CHARACTER; }
}
