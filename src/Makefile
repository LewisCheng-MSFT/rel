CC	= gcc
CFLAGS	= -O2
LEX	= flex
YACC	= bison

all: rel

rel: rel.o lex.yy.o parser.tab.o
	$(CC) $(CFLAGS) rel.o lex.yy.o parser.tab.o -o rel

rel.o: rel.c
	$(CC) $(CFLAGS) -c rel.c

lex.yy.o: lex.yy.c parser.tab.c
	$(CC) $(CFLAGS) -c lex.yy.c

parser.tab.o: parser.tab.c
	$(CC) $(CFLAGS) -c parser.tab.c

lex.yy.c: lex.l
	$(LEX) lex.l

parser.tab.c: parser.y
	$(YACC) -d parser.y

clean:
	rm -f *.o rel
	rm -f parser.tab.c parser.tab.h lex.yy.c


