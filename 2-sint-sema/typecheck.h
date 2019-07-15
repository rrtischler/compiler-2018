#include <stdio.h>
#include <string.h>

typedef enum eType { tVoid, tInt, tVector, tNull } eType;

typedef struct typeTable {
  char* name;
  eType type;
  int nParams;
  eType* types;
  // typeTable *next;
} typeTable;

void insertFun(char* name, eType type, int nParams, eType** types);
void insertVar(char* name, eType type);
int getFun(char* name, typeTable** fun);
int getVar(char* name, typeTable** var);
int findFun(char* name);
int findVar(char* name);
eType getVarType(char* name);

#define prt(a) printf("\n%d\n\n", a);