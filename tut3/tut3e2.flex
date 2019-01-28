%{
#include <stdio.h>
char output[100];
%}
digit	[0-9]
letter	[a-zA-Z]
pattern	{letter}+{digit}*
any	.*
%%
{pattern}	{printf("Pattern found: %s\n", yytext); strcat(output, yytext); strcat(output, "\n");}
{any}		{printf("Pattern not found.\n");}
%%
int main(){
    strncpy(output, "The output is: \n", strlen(output));
    yylex();
    printf("From main: %s", output);
    return 0;
    }