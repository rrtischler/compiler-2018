all: parser

parser.tab.c parser.tab.h: parser.y ast.h ast.c typecheck.h typecheck.c
	bison -d parser.y 

lex.yy.c: scanner.l parser.tab.h
	flex scanner.l

parser: lex.yy.c  parser.tab.c parser.tab.h
	gcc lex.yy.c parser.tab.c ast.c typecheck.c -lfl -o compilador
  
clean:
	rm -f lex.yy.c parser.tab.c parser.tab.h compilador

zip: makefile scanner.l parser.y ast.h ast.c
	make clean
	zip rtischler.zip makefile scanner.l parser.y ast.h ast.c typecheck.h typecheck.c

test: 
	./compilador tests/input.c tests/output.ast

cp:
	cp compilador autotest/

debug:
	gcc -g -O1 lex.yy.c parser.tab.c ast.c typecheck.c -lfl -o compilador

val:
	valgrind --leak-check=yes ./compilador tests/input.c tests/output.ast