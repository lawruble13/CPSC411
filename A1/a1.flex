%{
	/* Declarations */
	#include <stdio.h>
%}

DIGIT [0-9]
LETTER [a-zA-Z]
RESERVED bool|if|int|else|not|return|true|false|void|while
ID {LETTER}+
NUM {DIGIT}+
%%

{ID} 
     printf("Found an id: %s\n", yytext);
     

{NUM} 
      printf("Found a number: %s\n", yytext);

%%
