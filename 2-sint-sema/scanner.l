
%{
  //#include "tokens.h"
  #include "ast.h"
  #include "parser.tab.h"

  void yyerror(char *s);

  //int lineComment = 0;
%}

/*%option yylineno*/
%option noinput nounput noyywrap
/*%option batch debug*/

%x COMMENT

DIGIT [0-9]
LETTER [a-zA-Z]
IDENTIFIERS ({LETTER})({LETTER}|{DIGIT})*
IDERROR ({DIGIT})({LETTER}|{DIGIT})*
WHITESPACE [ \t\n]

%%

"else"                { return ELSE; }
"if"                  { return IF; }
"int"                 { return INT; }
"return"              { return RETURN; }
"void"                { return VOID; }
"while"               { return WHILE; }

"+"                   { return PLUS; }
"-"                   { return MINUS; }
"*"                   { return MULT; }
"/"                   { return DIV; }
"<"                   { return L; }
"<="                  { return LE; }
">"                   { return G; }
">="                  { return GE; }
"="                   { return ASSIGN; }
"=="                  { return E; }
"!="                  { return NE; }
";"                   { return *yytext; }
","                   { return *yytext; }
"("                   { return *yytext; }
")"                   { return *yytext; }
"["                   { return *yytext; }
"]"                   { return *yytext; }
"{"                   { return *yytext; }
"}"                   { return *yytext; }

{DIGIT}+              { yylval.iNum = atoi(yytext); return NUM; }

{IDENTIFIERS}         { yylval.iChar = strdup(yytext); return ID; }

"/*"                  { //lineComment = yylineno; 
                        BEGIN(COMMENT); }

{WHITESPACE}          { } //pular espaco, tabulacao, newline

<COMMENT>{
  [^*\n]*             { }
  [^*\n]*\n           { }
  "*"+[^*/\n]*        { }
  "*"+[^*/\n]*\n      { }
  "*/"                { BEGIN(INITIAL); }
  <<EOF>>             { BEGIN(INITIAL);
                        yytext = "/*";
                        //yylineno = lineComment;
                        // return ERROR; 
                        yyterminate();
                      }
}

{IDERROR}             |
.                     { // return ERROR; 
                        yyterminate(); }


%%
