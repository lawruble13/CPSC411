%option yylineno
%x comment
%x notsp

%{
#include <stdlib.h>
#include <stdio.h>

#define MATCH(name) MATCH2(name ":")
#define MATCH2(name) { printf("%d: " name " %s\n", yylineno, yytext); BEGIN(notsp); }
%}
letter	[a-zA-Z]
digit	[0-9]
space	[ \t\r\n]
notspace [^ \t\r\n]

RESERVED	    (bool|if|int|else|not|return|true|false|void|while)
SPECIAL		    ([+\-*/<>;,()\[\]{}]|[<>]=|==|!=|=|&&|\|\|)	

ID		{letter}+
NUM		{digit}+
%%
<INITIAL>{RESERVED} {
    MATCH("reserved word");
    BEGIN(notsp);
}

<INITIAL>{ID} {
    MATCH2("id, name=")
    BEGIN(notsp);
}
<INITIAL>{NUM} {
    MATCH("num");
    BEGIN(notsp);
}
<INITIAL,notsp>{SPECIAL} {
    MATCH("special symbol");
    BEGIN(INITIAL);
}
<INITIAL,notsp>\/\*     BEGIN(comment);
<INITIAL,notsp>\*\/     { printf("%d: ERROR: Unmatched */\n", yylineno); BEGIN(INITIAL); }
<INITIAL,notsp>{space}+ BEGIN(INITIAL);
<INITIAL>{notspace}    printf("%d: ERROR: %s\n", yylineno, yytext);

<comment>.          /* ignore */
<comment>\*\/       BEGIN(INITIAL);
<comment><<EOF>>	{ printf("%d: ERROR: EOF in comment\n", yylineno); BEGIN(INITIAL); }
%%
int main(int argc, char **argv)
{
    const char *src = "<stdin>";
    if (argc > 1) {
        src = argv[1];
        yyin = fopen(src, "r");
    } else {
        yyin = stdin;
    }

    printf("C- COMPILATION: %s\n", src);

    yylex();
}
