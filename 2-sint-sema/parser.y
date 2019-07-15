%{
#include <stdio.h>
#include <stdlib.h>
//#include <string.h>
#include <stdarg.h>
#include <string.h>
#include "ast.h"
//#include "typecheck.h"

void yyerror(const char *s);
void checkVarDeclarationType(nodeAST* node);
void checkPrintInputDecl(nodeAST* node);
void checkMainParams(nodeAST* node);
void checkDecFunc(nodeAST *func);
void checkDecVar(nodeAST *var);
eType checkFunCall(char *name, nodeAST *args);
void checkVarCall(nodeAST *node);
eType typeCheck(nodeAST *n1, nodeAST *n2);
void checkMain();
void checkIntSize(int i);
void checkDecParam(nodeAST* node);
void checkRetStmt(nodeAST *nodeExp);

int yylex(void);

extern FILE *yyin;
extern FILE *yyout;

int hasMain = 0;
typeTable *tbFun;
typeTable *tbVar;

nodeAST *pProgram;


%}


%union{
int     iNum;
char    *iChar;
nodeAST *node;
}

%start          pstart

//precisa de token print? <<<<<<<<<<<<<<<<<<<<<<

//tokens que serao usados no lexico
%token  <iChar> IF ELSE WHILE RETURN VOID INT
%token  <iNum> NUM
%token  <iChar> ID

%left  <iNum> E NE
%left  <iNum> L LE G GE
%left  <iNum> PLUS MINUS
%left  <iNum> MULT DIV
%right <iNum> ASSIGN
%left  '(' ')' // maior precedencia

// %nonassoc IF
// %nonassoc ELSE

%precedence IF
%precedence ELSE

%type <node> program
%type <node> declaration_list
%type <node> declaration
%type <node> var_declaration
%type <node> type_specifier
%type <node> fun_declaration
%type <node> params
%type <node> param_list
%type <node> param
%type <node> compound_stmt
%type <node> local_declarations
%type <node> statement_list
%type <node> statement
%type <node> expression_stmt
%type <node> selection_stmt
%type <node> iteration_stmt
%type <node> return_stmt
%type <node> expression
%type <node> var
%type <node> simple_expression
%type <iChar> relop
%type <node> additive_expression
%type <iChar> addop
%type <node> term
%type <iChar> mulop
%type <node> factor
%type <node> call
%type <node> args
%type <node> arg_list



//-----------------------------------------------------------------------------
%%
//-----------------------------------------------------------------------------

pstart                :   program                                     { checkMain(); pProgram = $1;/* printAST($1, yyout); */ /* freeNode($1); */ }

program               :   declaration_list                            { $$ = createNode(Eprogram, tNull, NULL, 1, $1); }
                      ;
declaration_list      :   declaration declaration_list                { $$ = createNode(Edeclaration_list, tNull, NULL, 2, $1, $2); }
                      |                                               { $$ = NULL; }
                      ;
declaration           :   var_declaration                             { $$ = $1; }
                      |   fun_declaration                             { $$ = $1; }
                      ;

var_declaration       :   type_specifier ID ';'                       { $$ = createNode(Evar_declaration, tInt, $2, 2, $1, createNodeID($2, tInt)); checkDecVar($$); }
                      |   type_specifier ID '[' NUM ']' ';'           { $$ = createNode(Evar_declaration, tVector, $2, 3, $1, createNodeID($2, tVector), createNodeNUM($4)); checkDecVar($$); checkIntSize($4); }
                      ;
type_specifier        :   INT                                         { $$ = createNode(Etype_specifier, tInt, "int", 0); }
                      |   VOID                                        { $$ = createNode(Etype_specifier, tVoid, "void", 0); }
                      ;                      

fun_declaration       :   type_specifier ID '(' params ')' compound_stmt { $$ = createNode(Efun_declaration, $1->type, $2, 4, $1, createNodeID($2, $1->type), $4, $6); checkDecFunc($$); }
                      ;
params                :   param_list                                  { $$ = createNode(Eparams, tNull, NULL, 1, $1); }
                      |   VOID                                        { $$ = createNode(Eparams, tVoid, NULL, 0); }
                      ;
param_list            :   param ',' param_list                        { $$ = createNode(Eparam_list, tNull, NULL, 2, $1, $3); }
                      |   param                                       { $$ = $1; }
                      ;
param                 :   type_specifier ID                           { $$ = createNode(Eparam, tInt, $2, 2, $1, createNodeID($2, tInt));  checkDecParam($1); }
                      |   type_specifier ID '[' ']'                   { $$ = createNode(Eparam, tVector, $2, 3, $1, createNodeID($2, tVector), createNode(Evector, tVector, NULL, 0)); checkDecParam($1); }
                      ;

compound_stmt         :   '{' local_declarations statement_list '}'   { $$ = createNode(Ecompound_stmt, tNull, NULL, 2, $2, $3); }
                      ;

local_declarations    :   local_declarations var_declaration          { $$ = createNode(Elocal_declarations, tNull, NULL, 2, $1, $2); }
                      |                                               { $$ = NULL; } 
                      ;
statement_list        :   statement_list statement                    { $$ = createNode(Estatement_list, tNull, NULL, 2, $1, $2  ); }
                      |                                               {  $$ = NULL; } 
                      ;

statement             :   expression_stmt                             { $$ = $1; } 
                      |   compound_stmt                               { $$ = $1; }
                      |   selection_stmt                              { $$ = $1; }
                      |   iteration_stmt                              { $$ = $1; }
                      |   return_stmt                                 { $$ = $1; }
                      ;
expression_stmt       :   expression ';'                              { $$ = $1; }
                      |   ';'                                         { $$ = createNode(Esemicolon, tNull, NULL, 0); }
                      ;

selection_stmt        :   IF '(' expression ')' statement             { $$ = createNode(Eselection_stmt, tNull, NULL, 2, $3, $5); }
                      | IF '(' expression ')' statement ELSE statement{ $$ = createNode(Eselection_stmt, tNull, NULL, 3, $3, $5, $7); }
                      ;

iteration_stmt        :   WHILE '(' expression ')' statement          { $$ = createNode(Eiteration_stmt, tNull, NULL, 2, $3, $5); }
                      ;

return_stmt           :   RETURN ';'                                  { $$ = createNode(Ereturn_stmt, tVoid, NULL, 0); }
                      |   RETURN expression ';'                       { checkRetStmt($2); $$ = createNode(Ereturn_stmt, $2->type, NULL, 1, $2); }
                      ;

expression            :   var ASSIGN expression                       { $$ = createNode(Eexpression, typeCheck($1, $3), "=", 2, $1, $3); }
                      |   simple_expression                           { $$ = $1; }

var                   :   ID                                          { $$ = createNode(Evar, tInt, $1, 1, createNodeID($1, tInt)); checkVarCall($$); }
                      |   ID '[' expression ']'                       { $$ = createNode(Evar, tInt, $1, 2, createNodeID($1, tVector), $3); checkVarCall($$); }
                      ;

simple_expression     :  additive_expression relop additive_expression{ $$ = createNode(Esimple_expression, typeCheck($1, $3), $2, 2, $1, $3); }
                      |   additive_expression                         { $$ = $1; }
relop                 :   E                                           { $$ = "=="; }
                      |   NE                                          { $$ = "!="; }
                      |   L                                           { $$ = "<"; }
                      |   LE                                          { $$ = "<="; }
                      |   G                                           { $$ = ">"; }
                      |   GE                                          { $$ = ">="; }
                      ;

additive_expression   :   additive_expression addop term              { $$ = createNode(Eadditive_expression, typeCheck($1, $3), $2, 2, $1, $3); }
                      |   term                                        { $$ = $1; }
addop                 :   PLUS                                        { $$ = "+"; }
                      |   MINUS                                       { $$ = "-"; }
term                  :   term mulop factor                           { $$ = createNode(Eterm, typeCheck($1, $3),$2, 2, $1, $3); }
                      |   factor                                      { $$ = $1; }
mulop                 :   MULT                                        { $$ = "*"; }
                      |   DIV                                         { $$ = "/"; }
                      ;

factor                :   '(' expression ')'                          { $$ = $2; }
                      |   var                                         { $$ = $1; }
                      |   call                                        { $$ = $1; } 
                      |   NUM                                         { $$ = createNodeNUM($1); checkIntSize($1); }
                      ;

call                  :   ID '(' args ')'                             { eType tp = checkFunCall((char*)$1, $3);  $$ = createNode(Ecall, tp, $1, 2, createNodeID($1, tp), $3); } /*buscar o tipo da call pra mandar pra cima*/
                      ;
args                  :   arg_list                                    { $$ = createNode(Eargs, tNull, NULL, 1, $1); }
                      |   /* empty */                                 { $$ = createNode(Eargs, tVoid, NULL, 0); }
                      ;
arg_list              :   expression ',' arg_list                     { $$ = createNode(Earg_list, tNull, NULL, 2, $1, $3); }
                      |   expression                                  { $$ = $1; }
                      ;



%%


void yyerror(const char *s) {    
    fprintf(stdout, "\n%s\n\n", s);
    exit(EXIT_FAILURE);
}

void checkPrintInputDecl(nodeAST* node){
  if ( !strcmp((char*)node->data, "input"))
    yyerror("cant redefine input()");
  if ( !strcmp((char*)node->data, "println"))
    yyerror("cant redefine println()");
}

void checkMainParams(nodeAST* node){
  if ( !strcmp((char*)node->data, "main") && hasMain)
    yyerror("main already defined");
  if (!strcmp((char*)node->data, "main")){    
    hasMain = 1;
    if( strcmp((char*)node->childs[0]->data,"void"))
      yyerror("main type different from void");
    else if ((int)node->childs[2]->nChilds != 0)
      yyerror("main cant have params");   
  }
}

void checkDecFunc(nodeAST *func){
  checkMainParams(func);
  checkPrintInputDecl(func);
  if (findFun((char*)func->data)) //checa se já foi declarada
    yyerror("function already declared");
  else{ //insere na tabela de funcoes
    //func->childs[2]  //params
    eType *types = NULL;
    int nParams = getParamsTypes(func->childs[2], &types);
    if (nParams == -1)
      yyerror("params names identical");
    insertFun(func->data, func->type, nParams, &types);
  }
}

void checkVarDeclarationType(nodeAST* node){
  if( !strcmp((char*)node->childs[0]->data, "void"))
    yyerror("var type cant be void");
}

void checkDecParam(nodeAST* node){
  if( node->type == tVoid)
    yyerror("param type cant be void");
}

void checkDecVar(nodeAST *node){
  checkVarDeclarationType(node);
  if (findVar((char*)node->data)) //checa se já foi declarada
    yyerror("variable already declared");
  else
    insertVar((char*)node->data, node->type);
}

 // buscar a funcao já declarada, 
 // conferir a quantidade e tipos dos args
eType checkFunCall(char *name, nodeAST *args){
  typeTable *func;
  
  if (!getFun(name, &func))
    yyerror("function not declared");

  // checar os argumentos aqui! <<<<<<<<<<<<<<<<<<<<<<<<<<<
    eType *types = NULL;
    int nArgs = getArgsTypes(args, &types);
    if (nArgs != func->nParams)
      yyerror("number of args dont match");
    if (!checkArgs(name, nArgs, &types))
      yyerror("type of args dont match");
    
  return func->type; // colocar o tipo certo aqui!
}

void checkVarCall(nodeAST *node){
  typeTable *var;
  if (!getVar((char*)node->childs[0]->data, &var))
    yyerror("var not declared");
  if (var->type != node->childs[0]->type)
    yyerror("var of different type");
}

eType typeCheck(nodeAST *n1, nodeAST *n2){
  if (n1 == NULL || n2 == NULL ||  n1->type  != n2->type)
    yyerror("type error");
  return n1->type;
}

void checkMain(){
  if (!hasMain)
    yyerror("no main defined");
}

void checkIntSize(int i){
  if (i <= -2147483648 || i >= 2147483648 )
    yyerror("int overflow");
}

void checkRetStmt(nodeAST *nodeExp){
  if (nodeExp->type != tInt)
    yyerror("return has to be int");
}





//------------MAIN--------------

int main(int argc, char *argv[])
{
  if (argc != 3) {
    printf("Quantidade de argumentos invalida!\n");
    return 1;
  }
  yyin = fopen(argv[1], "r");
  if (yyin == NULL) {
    printf("Erro ao abrir o arquivo: %s", argv[1]);
    return 1;
  }
  yyout = fopen(argv[2], "w");
  if (yyout == NULL) {
    printf("Erro ao abrir o arquivo: %s", argv[2]);
    fclose(yyin);
    return 1;
  }

  yyparse();

  printAST(pProgram, yyout);

  fclose(yyin);
  fclose(yyout);

  printf("\nParsing complete!\n\n");

  return 0;


}