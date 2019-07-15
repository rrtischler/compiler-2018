
%{
  FILE *fp;
  int lineComment = 0;
%}

%option noyywrap
%option nounput yylineno
%x COMMENT

DIGITO [0-9]
LETRA [a-zA-Z]
IDENTIFICADOR ({LETRA})({LETRA}|{DIGITO})*
IDERRO ({DIGITO})({LETRA}|{DIGITO})*

%%

"else"              { fprintf(fp, "(%d,KEY,\"%s\")\n", yylineno, yytext); }
"if"                { fprintf(fp, "(%d,KEY,\"%s\")\n", yylineno, yytext); }
"int"               { fprintf(fp, "(%d,KEY,\"%s\")\n", yylineno, yytext); }
"return"            { fprintf(fp, "(%d,KEY,\"%s\")\n", yylineno, yytext); }
"void"              { fprintf(fp, "(%d,KEY,\"%s\")\n", yylineno, yytext); }
"while"             { fprintf(fp, "(%d,KEY,\"%s\")\n", yylineno, yytext); }

"+"                 { fprintf(fp, "(%d,SYM,\"%s\")\n", yylineno, yytext); }
"-"                 { fprintf(fp, "(%d,SYM,\"%s\")\n", yylineno, yytext); }
"*"                 { fprintf(fp, "(%d,SYM,\"%s\")\n", yylineno, yytext); }
"/"                 { fprintf(fp, "(%d,SYM,\"%s\")\n", yylineno, yytext); }
"<"                 { fprintf(fp, "(%d,SYM,\"%s\")\n", yylineno, yytext); }
"<="                { fprintf(fp, "(%d,SYM,\"%s\")\n", yylineno, yytext); }
">"                 { fprintf(fp, "(%d,SYM,\"%s\")\n", yylineno, yytext); }
">="                { fprintf(fp, "(%d,SYM,\"%s\")\n", yylineno, yytext); }
"=="                { fprintf(fp, "(%d,SYM,\"%s\")\n", yylineno, yytext); }
"!="                { fprintf(fp, "(%d,SYM,\"%s\")\n", yylineno, yytext); }
"="                 { fprintf(fp, "(%d,SYM,\"%s\")\n", yylineno, yytext); }
";"                 { fprintf(fp, "(%d,SYM,\"%s\")\n", yylineno, yytext); }
","                 { fprintf(fp, "(%d,SYM,\"%s\")\n", yylineno, yytext); }
"("                 { fprintf(fp, "(%d,SYM,\"%s\")\n", yylineno, yytext); }
")"                 { fprintf(fp, "(%d,SYM,\"%s\")\n", yylineno, yytext); }
"["                 { fprintf(fp, "(%d,SYM,\"%s\")\n", yylineno, yytext); }
"]"                 { fprintf(fp, "(%d,SYM,\"%s\")\n", yylineno, yytext); }
"{"                 { fprintf(fp, "(%d,SYM,\"%s\")\n", yylineno, yytext); }
"}"                 { fprintf(fp, "(%d,SYM,\"%s\")\n", yylineno, yytext); }

{DIGITO}+           { fprintf(fp, "(%d,NUM,\"%s\")\n", yylineno, yytext); }

{IDENTIFICADOR}     { fprintf(fp, "(%d,ID,\"%s\")\n", yylineno, yytext); }

"/*"                { lineComment = yylineno; BEGIN(COMMENT); }

[ \t\n]           ; //pular espaco, tabulacao, newline

<COMMENT>{
  [^*\n]*           ;
  "*"+[^*/\n]*      ;
  \n                ;
  "*/"              { BEGIN(INITIAL); }
  <<EOF>>           { fprintf(fp, "(%d,ERROR,\"/*\")\n", lineComment);
                      BEGIN(INITIAL);
                    }
}

{IDERRO}            |
.                   { fprintf(fp, "(%d,ERROR,\"%s\")\n", yylineno, yytext);
                      return 0;
                    }

%%

// utilizado manual do Flex como referencia
int main(int argc, char *argv[])
{
  if( argc != 3){
    printf("Quantidade de argumentos invalida!\n");
    return 1;
  }
  yyin = fopen(argv[1], "r");
  if (yyin == NULL){
      printf("Erro ao abrir o arquivo: %s", argv[1]);
      return 1;
  }
  fp = fopen(argv[2], "w+");
  if (fp == NULL){
      printf("Erro ao abrir o arquivo: %s", argv[2]);
      return 1;
  }
  yylex();
  fclose(yyin);
  fclose(fp);
  return 0;
}