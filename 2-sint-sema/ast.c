#include "ast.h"

#ifndef NULL
#define NULL 0
#endif

nodeAST *createNode(nodeEnum nodeType, eType type, void *data, int nChilds,
                    ...) {
  va_list list_variaveis;  // nodeType especial definido em stdarg.h
  nodeAST *node;
  node = malloc(sizeof(nodeAST *));
  // node = malloc(sizeof(nodeAST));
  int i;

  if (nChilds != 0) {
    if (!(node->childs = malloc(nChilds * sizeof(nodeAST *)))) {
      fprintf(stderr, "Memory allocation failed!\n");
      fflush(stderr);
      abort();
    }
    // yyerror("Memory allocation failed!");

    va_start(list_variaveis, nChilds);  // iniciar va_list

    for (i = 0; i < nChilds; i++)
      node->childs[i] = va_arg(list_variaveis, nodeAST *);

    va_end(list_variaveis);  // limpar va_list
  }

  node->nChilds = nChilds;
  node->nodeType = nodeType;  // setando nodeType do Node
  node->data = data;
  node->type =
      type;  // CORRIGIR ESSA
             // MERDA!<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  return node;
}

void freeNode(nodeAST *node) {
  int i;

  if (!node) return;
  if (node->nChilds > 0) {
    for (i = 0; i < node->nChilds; i++) freeNode(node->childs[i]);
    free(node->childs);
  }
  free(node);
}

nodeAST *createNodeID(void *data, eType type) {
  return createNode(Eid, type, data, 0);
}

nodeAST *createNodeNUM(int data) { return createNode(Enum, tInt, data, 0); }

int getParamsTypes(nodeAST *params, eType **types) {
  if (params->type == tVoid)
    return 0;
  else {
    int nParams = getParams(params->childs[0]);
    // prt(nParams)
    nodeAST *pList =
        params->childs[0];  // pega paramlist (ou param, se tiver só 1)
    *types = (eType *)malloc(nParams * sizeof(eType));
    char *tNames[nParams];
    for (int i = 0; i < nParams; i++) {
      if (pList->nodeType != Eparam_list) {
        (*types)[i] = pList->type;  // aqui é param
        tNames[i] = pList->data;
      } else {
        (*types)[i] = pList->childs[0]->type;
        tNames[i] = pList->childs[0]->data;
        pList = pList->childs[1];
      }
    }

    for (int i = 0; i < nParams; i++)
      for (int j = 0; j < i; j++)
        if (!strcmp(tNames[i], tNames[j])) return -1;

    return nParams;
  }
}

int getParams(nodeAST *paramlist) {
  if (paramlist->nodeType == Eparam)
    return 1;
  else
    return 1 + getParams(paramlist->childs[1]);
}

int getArgsTypes(nodeAST *args, eType **types) {
  if (args->type == tVoid)
    return 0;
  else {
    int nArgs = getArgs(args->childs[0]);
    nodeAST *aList = args->childs[0];
    *types = (eType *)malloc(nArgs * sizeof(eType));
    for (int i = 0; i < nArgs; i++) {
      if (aList->nodeType != Earg_list)  // caso for expression, no ultimo arg
        (*types)[i] = aList->type;
      else {
        (*types)[i] = aList->childs[0]->type;  // caso for arglist, olhar o expression
        aList = aList->childs[1];
      }
    }
    return nArgs;
  }
}

int getArgs(nodeAST *arglist) {
  if (arglist->nodeType != Earg_list)
    return 1;
  else
    return 1 + getArgs(arglist->childs[1]);
}

// comparar parametros e argumentos
int checkArgs(char *id, int nArgs, eType **aTypes) {
  typeTable *fFun;
  getFun(id, &fFun);
  for (int i = 0; i < nArgs; i++) {
    if ((*aTypes)[i] != fFun->types[i]) return 0;
  }
  return 1;
}

void printAST(nodeAST *node, FILE *fp) {
  if (node != NULL) switch (node->nodeType) {
      case Enum:
        fprintf(fp, "[%d]", (int)(node->data));
        break;

      case Eid:
        fprintf(fp, "[%s]", (char *)node->data);
        break;

      case Evector:
        fprintf(fp, "[\\[\\]]");
        break;

      case Eprogram:
        fprintf(fp, "[program ");
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        fprintf(fp, "]");
        break;

      case Edeclaration_list:
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        break;

      case Evar_declaration:
        fprintf(fp, "[var-declaration ");
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        fprintf(fp, "]");
        break;

      case Etype_specifier:
        fprintf(fp, "[%s]", (char *)node->data);  // checar o dado aqui!
        break;

      case Efun_declaration:
        fprintf(fp, "[fun-declaration ");
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        fprintf(fp, "]");
        break;

      case Eparams:
        fprintf(fp, "[params ");
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        fprintf(fp, "]");
        break;

      case Eparam_list:
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        break;

      case Eparam:
        fprintf(fp, "[param ");
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        fprintf(fp, "]");
        break;

      case Ecompound_stmt:
        fprintf(fp, "[compound-stmt ");
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        fprintf(fp, "]");
        break;

      case Elocal_declarations:
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        break;

      case Estatement_list:
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        break;

      case Eselection_stmt:
        fprintf(fp, "[selection-stmt ");
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        fprintf(fp, "]");
        break;

      case Eiteration_stmt:
        fprintf(fp, "[iteration-stmt ");
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        fprintf(fp, "]");
        break;

      case Ereturn_stmt:
        fprintf(fp, "[return-stmt ");
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        fprintf(fp, "]");
        break;

      case Eexpression:
        fprintf(fp, "[= ");
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        fprintf(fp, "]");
        break;

      case Evar:
        fprintf(fp, "[var ");
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        fprintf(fp, "]");
        break;

      case Esimple_expression:
        fprintf(fp, "[%s ", (char *)node->data);
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        fprintf(fp, "]");
        break;

      case Eadditive_expression:
        fprintf(fp, "[%s ", (char *)node->data);
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        fprintf(fp, "]");
        break;

      case Eterm:
        fprintf(fp, "[%s ", (char *)node->data);
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        fprintf(fp, "]");
        break;

      case Ecall:
        fprintf(fp, "[call ");
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        fprintf(fp, "]");
        break;

      case Eargs:
        fprintf(fp, "[args ");
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        fprintf(fp, "]");
        break;

      case Earg_list:
        for (int i = 0; i < node->nChilds; i++) printAST(node->childs[i], fp);
        break;

      case Esemicolon:
        fprintf(fp, "[;]");
        break;

      default:
        // printf("ERROR!\n");
        break;
    }

  return;
}
