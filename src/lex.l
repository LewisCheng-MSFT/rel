/*
 ============================================================================
 Name        : lex.l
 Author      : Lewis Cheng
 Version     :
 Copyright   : Your copyright notice
 Description : Lexer
 ============================================================================
 */
%{
#define YYSTYPE const char *
#include "parser.tab.h"
	
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#undef YY_INPUT
#define YY_INPUT(buf, result, max_size) \
	if (*pinput == 0) { \
		buf[0] = EOF; \
		result = YY_NULL; \
	} else { \
		buf[0] = *pinput++; \
		result = 1; \
	}

char *pinput;
%}

D [0-9]
L [_a-zA-Z]

%%
{L}({L}|{D})* {
	yylval = strdup(yytext);
	return IDENTIFIER;
}

[+-]?{D}+ {
	yylval = strdup(yytext);
	return NUMBER;
}

[+-]?{D}+"."{D}+ {
	yylval = strdup(yytext);
	return NUMBER;
}

[*+-.(,)] {
	yylval = NULL;
	return *yytext;
}

[ \t] {
	// Ignore white characters.
}

. {
	fprintf(stderr, "Error: Unrecognized character %s\n", yytext);
	exit(EXIT_FAILURE);
}

%%
int yywrap()
{
	return 1;
}

