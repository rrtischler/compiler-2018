#include <stdio.h>
#include "tokens.h"

extern int yylex();
extern FILE *yyin, *yyout;
extern int yylineno;
extern char* yytext;

char* tokenName[] = {NULL, "ID", "NUM", "KEY", "SYM", "ERROR"};

int main(int argc, char* argv[]) {
  if (argc != 3) {
    printf("Quantidade de argumentos invalida!\n");
    return 1;
  }
  yyin = fopen(argv[1], "r");
  if (yyin == NULL) {
    printf("Erro ao abrir o arquivo: %s", argv[1]);
    return 1;
  }
  yyout = fopen(argv[2], "w+");
  if (yyout == NULL) {
    printf("Erro ao abrir o arquivo: %s", argv[2]);
    fclose(yyin);
    return 1;
  }

  // int ntoken = yylex();
  int ntoken;
  while (ntoken = yylex()) {
    fprintf(yyout, "(%d,%s,\"%s\")\n", yylineno, tokenName[ntoken], yytext);
    if (ntoken == ERROR) {
      printf("Lexical error on line: %d\n", yylineno);
      fclose(yyin);
      fclose(yyout);
      return 0;
    }
    // ntoken = yylex();
  }

  fclose(yyin);
  fclose(yyout);

  printf("Lexical analysis complete!\n");

  return 0;
}