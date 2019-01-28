%{
#include <stdio.h>
%}
digit	[0-9]
letter	[a-zA-Z]
email	{letter}+\.{letter}+{digit}*@ucalgary.ca
any	.*

%%
{email}	{printf("Email found: %s\n",yytext);}
{any}	{printf("No email found.\n");}
%%
int main(){
    yylex();
    return 0;
}