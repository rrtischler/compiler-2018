all: lexico

lex.yy.c: scanner.l tokens.h
	flex scanner.l

lexico: lex.yy.c tokens.h lexico.c
	gcc lexico.c lex.yy.c -lfl -o compilador
  
clean:
	rm -f lex.yy.c compilador

test: lexico
	./compilador tests/input.c tests/output.lex
