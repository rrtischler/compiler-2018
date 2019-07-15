#include "typecheck.h"

typeTable tbFun[256];
typeTable tbVar[256];

int iFun = 0;
int iVar = 0;

void insertFun(char* name, eType type, int nParams, eType** types) {
  tbFun[iFun].name = name;
  tbFun[iFun].type = type;
  tbFun[iFun].nParams = nParams;
  tbFun[iFun].types = *types;
  // tbFun[iFun].types = NULL;
  // prt(*types[iFun])
  iFun++;
}

void insertVar(char* name, eType type) {
  tbVar[iVar].name = name;
  tbVar[iVar].type = type;
  iVar++;
}

int getFun(char* name, typeTable** fun) {
  for (int i = 0; i < iFun; i++)
    if (!strcmp(tbFun[i].name, name)) {
      *fun = &tbFun[i];
      return 1;
    }
  return 0;
}

int getVar(char* name, typeTable** var) {
  for (int i = 0; i < iVar; i++)
    if (!strcmp(tbVar[i].name, name)) {
      *var = &tbVar[i];
      return 1;
    }
  return 0;
}

int findFun(char* name) {
  for (int i = 0; i < iFun; i++)
    if (!strcmp(tbFun[i].name, name)) return 1;
  return 0;
}

int findVar(char* name) {
  for (int i = 0; i < iVar; i++)
    if (!strcmp(tbVar[i].name, name)) return 1;
  return 0;
}

eType getVarType(char* name) {
  typeTable* fFun;
  getVar(name, &fFun);
  return fFun->type;
}