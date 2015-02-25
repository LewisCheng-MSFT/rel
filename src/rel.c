/*
 ============================================================================
 Name        : rel.c
 Author      : Lewis Cheng
 Version     :
 Copyright   : Your copyright notice
 Description : Hello World in C, Ansi-style
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>

#define PRESERVED

extern char *pinput;
extern int yyparse();

extern int last_variable_index;

FILE *script;

int main(int argc, char *argv[])
{
	if (argc != 2) {
		printf("Usage: rel \"expression\"\n");
		return EXIT_SUCCESS;
	}
	pinput = argv[1];

	script = fopen("extract.sh", "w");
	if (script == NULL) {
		fprintf(stderr, "Error: Cannot open extract.sh\n");
		return EXIT_FAILURE;
	}

	fprintf(script, "#!/bin/bash\n");
	fprintf(script, "# script extracting records from:\n");
	fprintf(script, "# \"%s\"\n\n", pinput);

	yyparse();

	fprintf(script, "# print result!\n");
	fprintf(script, "sort -n -k2 T%d\n\n", last_variable_index);

#ifndef PRESERVED
	fprintf(script, "# clean up\n");
	int i;
	for (i = 0; i <= last_variable_index; ++i)
		fprintf(script, "rm -f T%d\n", i);

	fprintf(script, "rm -f extract.sh\n");
#endif

	fclose(script);

	system("chmod +x extract.sh");
	system("./extract.sh");

	return EXIT_SUCCESS;
}
