/*
 ============================================================================
 Name        : lex.l
 Author      : Lewis Cheng
 Version     :
 Copyright   : Your copyright notice
 Description : Parser
 ============================================================================
 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
	
#define YYSTYPE const char *

struct argument_node_t {
	double value;
	struct argument_node_t *link;
};

struct argument_node_t *last_argument;
size_t argument_count;

extern FILE *script;

extern int yylex();
extern void yyerror(const char *);
extern void add_argument(double);
extern void clean_arguments();
extern const char *get_free_variable();
%}

%token IDENTIFIER
%token NUMBER
%start set_expression

%%
set_expression
	: intersect_expression
	{
		$$ = $1;
	}
	| set_expression '+' intersect_expression
	{
		$$ = get_free_variable();
		fprintf(script, "# %s = %s union %s\n", $$, $1, $3);
		fprintf(script, "sort %s %s | uniq > %s\n\n", $1, $3, $$);
	}
	| set_expression '-' intersect_expression
	{
		$$ = get_free_variable();
		fprintf(script, "# %s = %s minus %s\n", $$, $1, $3);
		fprintf(script, "sort %s %s %s | uniq -u > %s\n\n", $1, $3, $3, $$);
	}
	
intersect_expression
	: postfix_expression
	{
		$$ = $1;
	}
	| intersect_expression '*' postfix_expression
	{
		$$ = get_free_variable();
		fprintf(script, "# %s = %s intersect %s\n", $$, $1, $3);
		fprintf(script, "sort %s %s | uniq -d > %s\n\n", $1, $3, $$);
	}
	
postfix_expression
	: primary_expression
	{
		$$ = $1;
	}
	| postfix_expression '.' IDENTIFIER '(' ')'
	{
		$$ = get_free_variable();
		fprintf(script, "# %s = %s.%s\n", $$, $1, $3);
		fprintf(script, "gawk -f %s %s > %s\n\n", $3, $1, $$);
	}
	| postfix_expression '.' IDENTIFIER '(' argument_list ')'
	{
		$$ = get_free_variable();
		fprintf(script, "# %s = %s.%s\n", $$, $1, $3);
		fprintf(script, "gawk -f %s ", $3);
		
		int i = argument_count;
		struct argument_node_t *p = last_argument;
		while (p) {
			fprintf(script, "-v v%d=%.2f ", i, p->value);
			p = p->link;
			--i;
		}
		
		fprintf(script, "%s > %s\n\n", $1, $$);
		
		clean_arguments();
	}
	
primary_expression
	: IDENTIFIER
	{
		$$ = $1;
	}
	| '(' set_expression ')'
	{
		$$ = $2;
	}

argument_list
	: NUMBER
	{
		add_argument(atof((const char *)$1));
	}
	| argument_list ',' NUMBER
	{
		add_argument(atof((const char *)$3));
	}

%%
void yyerror(const char *msg)
{
	fprintf(stderr, "Error: %s\n", msg);
	exit(EXIT_FAILURE);
}

void add_argument(double value)
{
	struct argument_node_t *node = malloc(sizeof(struct argument_node_t));
	node->value = value;
	node->link = last_argument;
	last_argument = node;
	argument_count++;
}

void clean_arguments()
{
	struct argument_node_t *p = last_argument;
	while (p) {
		struct argument_node_t *t = p->link;
		free(p);
		p = t;
	}
	last_argument = NULL;
	argument_count = 0;
}

#define TEMP_VARIABLE_LENGTH 8

int last_variable_index = -1;

const char *get_free_variable()
{
	++last_variable_index;
	
	char *result = malloc(TEMP_VARIABLE_LENGTH);
	sprintf(result, "T%d", last_variable_index);
	
	return result;
}

