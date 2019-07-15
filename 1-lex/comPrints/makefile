all: lexico

lex.yy.c: lexico.l
	flex lexico.l

lexico: lex.yy.c 
	gcc lex.yy.c -lfl -o compilador

clean:
	rm -f lex.yy.c compilador

test:
	./compilador tests/input.c tests/output.lex
