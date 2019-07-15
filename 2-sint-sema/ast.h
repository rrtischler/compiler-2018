#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "typecheck.h"

typedef enum nodeEnum {
  Enum,
  Eid,
  Eprogram,
  Edeclaration_list,
  Evar_declaration,
  Etype_specifier,
  Efun_declaration,
  Eparams,
  Eparam_list,
  Eparam,
  Ecompound_stmt,
  Elocal_declarations,
  Estatement_list,
  Eselection_stmt,
  Eiteration_stmt,
  Ereturn_stmt,
  Eexpression,
  Evar,
  Esimple_expression,
  Eadditive_expression,
  Eterm,
  Ecall,
  Eargs,
  Earg_list,
  Evector,
  Esemicolon
} nodeEnum;

typedef struct nodeAST {
  nodeEnum nodeType;
  eType type;
  int nChilds;
  void *data;
  struct nodeAST **childs;
} nodeAST;

typedef struct globVar {
  char nome_var[50];
  void *valor;
  struct globVar *prox;
} globVar;

nodeAST *createNode(nodeEnum nodeType, eType type, void *data, int nChilds,
                    ...);
void freeNode(nodeAST *n);
void printAST(nodeAST *node, FILE *fp);
nodeAST *createNodeID(void *data, eType type);
nodeAST *createNodeNUM(int data);
int getParamsTypes(nodeAST *params, eType **types);
int getParams(nodeAST *paramlist);
int getArgsTypes(nodeAST *args, eType **types);
int getArgs(nodeAST *arglist);
int checkArgs(char *id, int nArgs, eType **aTypes);
