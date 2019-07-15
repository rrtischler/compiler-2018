
%{
  #include "tokens.h"
  int lineComment = 0;
%}

%option noyywrap
%option nounput yylineno
%x COMMENT

DIGIT [0-9]
LETTER [a-zA-Z]
IDENTIFIERS ({LETTER})({LETTER}|{DIGIT})*
IDERROR ({DIGIT})({LETTER}|{DIGIT})*
WHITESPACE [ \t\n]

%%

"else"                |
"if"                  |
"int"                 |
"return"              |
"void"                |
"while"               { return KEY; }

"+"                   |
"-"                   |
"*"                   |
"/"                   |
"<"                   |
"<="                  |
">"                   |
">="                  |
"=="                  |
"!="                  |
"="                   |
";"                   |
","                   |
"("                   |
")"                   |
"["                   |
"]"                   |
"{"                   |
"}"                   { return SYM; }

{DIGIT}+              { return NUM; }

{IDENTIFIERS}         { return ID; }

"/*"                  { lineComment = yylineno; BEGIN(COMMENT); }

{WHITESPACE}          { } //pular espaco, tabulacao, newline

<COMMENT>{
  [^*\n]*             { }
  [^*\n]*\n           { }
  "*"+[^*/\n]*        { }
  "*"+[^*/\n]*\n      { }
  "*/"                { BEGIN(INITIAL); }
  <<EOF>>             { BEGIN(INITIAL);
                        yytext = "/*";
                        yylineno = lineComment;
                        return ERROR;
                      }
}

{IDERROR}             |
.                     { return ERROR; }


%%
