%{
	/* Declarations */
	#include <stdio.h>
	#ifndef DEFAULT_OUTPUT
	#define DEFAULT_OUTPUT "scanner.res"
	#endif
	
	int lineNo = 1;

	typedef enum{
		/* Reserved words */
		BOOL, IF, INT, ELSE, NOT, RETURN, TRUE, FALSE, VOID, WHILE,
		/* Special characters */
		PLUS, MINUS, TIMES, DIV, LT, GT, SEMI, COMMA, OP, CP, OSB, CSB, OCB, CCB, LTE, GTE, NE, E, ASSN, LAND, LOR,
		/* Other tokes */
		ID, NUM,
		/* Bookkeeping */
		SYM_ERROR, EOF_ERROR, UNMATCHED_ERROR, END, UNK
	} TokenType;

	typedef enum{
		CAT_RWORD, CAT_SPEC, CAT_ID, CAT_NUM, CAT_ERR, CAT_END
	} TokenCat;

	typedef struct{
		TokenType type;
		TokenCat cat;
		const void* data;
		unsigned char alloc;
	} Token;
	Token currentToken;
	Token* Token_new(TokenType, TokenCat, const void*);
	void Token_init(Token*, TokenType, TokenCat, const void*);
	void Token_dest(Token*);
	void printToken(Token, FILE*);
%}

DIGIT		[0-9]
LETTER		[a-zA-Z]
ID		{LETTER}+
NUM		{DIGIT}+
OCOM		\/\*
CCOM		\*\/
SPACE		[ \t]
NEWLINE		\r?\n
OTHER		.
%x COMMENT
%%

{SPACE}	{/*Consume whitespace*/}

bool	{Token_init(&currentToken, BOOL, CAT_RWORD, NULL); return 0;}
if	{Token_init(&currentToken, IF, CAT_RWORD, NULL); return 0;}
int	{Token_init(&currentToken, INT, CAT_RWORD, NULL); return 0;}
else	{Token_init(&currentToken, ELSE, CAT_RWORD, NULL); return 0;}
not	{Token_init(&currentToken, NOT, CAT_RWORD, NULL); return 0;}
return	{Token_init(&currentToken, RETURN, CAT_RWORD, NULL); return 0;}
true	{Token_init(&currentToken, TRUE, CAT_RWORD, NULL); return 0;}
false	{Token_init(&currentToken, FALSE, CAT_RWORD, NULL); return 0;}
void	{Token_init(&currentToken, VOID, CAT_RWORD, NULL); return 0;}
while	{Token_init(&currentToken, WHILE, CAT_RWORD, NULL); return 0;}

\+	{Token_init(&currentToken, PLUS, CAT_SPEC, NULL); return 0;}
-	{Token_init(&currentToken, MINUS, CAT_SPEC, NULL); return 0;}
\*	{Token_init(&currentToken, TIMES, CAT_SPEC, NULL); return 0;}
\/	{Token_init(&currentToken, DIV, CAT_SPEC, NULL); return 0;}
\<	{Token_init(&currentToken, LT, CAT_SPEC, NULL); return 0;}
\<=	{Token_init(&currentToken, LTE, CAT_SPEC, NULL); return 0;}
>	{Token_init(&currentToken, GT, CAT_SPEC, NULL); return 0;}
>=	{Token_init(&currentToken, GTE, CAT_SPEC, NULL); return 0;}
==	{Token_init(&currentToken, E, CAT_SPEC, NULL); return 0;}
!=	{Token_init(&currentToken, NE, CAT_SPEC, NULL); return 0;}
=	{Token_init(&currentToken, ASSN, CAT_SPEC, NULL); return 0;}
&&	{Token_init(&currentToken, LAND, CAT_SPEC, NULL); return 0;}
\|\|	{Token_init(&currentToken, LOR, CAT_SPEC, NULL); return 0;}
;	{Token_init(&currentToken, SEMI, CAT_SPEC, NULL); return 0;}
,	{Token_init(&currentToken, COMMA, CAT_SPEC, NULL); return 0;}
\(	{Token_init(&currentToken, OP, CAT_SPEC, NULL); return 0;}
\)	{Token_init(&currentToken, CP, CAT_SPEC, NULL); return 0;}
\[	{Token_init(&currentToken, OSB, CAT_SPEC, NULL); return 0;}
]	{Token_init(&currentToken, CSB, CAT_SPEC, NULL); return 0;}
\{	{Token_init(&currentToken, OCB, CAT_SPEC, NULL); return 0;}
\}	{Token_init(&currentToken, CCB, CAT_SPEC, NULL); return 0;}

<INITIAL>{ID}	{Token_init(&currentToken, ID, CAT_ID, yytext); return 0;}

<INITIAL>{OCOM}	{BEGIN(COMMENT);}

<INITIAL>{CCOM}	{Token_init(&currentToken, UNMATCHED_ERROR, CAT_ERR, NULL); return 0;}

<INITIAL>{NUM}	{Token_init(&currentToken, NUM, CAT_NUM, yytext); return 0;}

<INITIAL,COMMENT>{NEWLINE} {lineNo++;}

<INITIAL>{OTHER}	   {Token_init(&currentToken, SYM_ERROR, CAT_ERR, yytext); return 0;}

<INITIAL><<EOF>>	   {Token_init(&currentToken, END, CAT_END, NULL); return 0;}

<COMMENT>{CCOM}		   {BEGIN(INITIAL);}

<COMMENT><<EOF>>	   {Token_init(&currentToken, EOF_ERROR, CAT_END, NULL); return 0;}
			    
<COMMENT>{OTHER}	    {/* Consume comment contents */}
%%
void main(int argc, char** argv){
     char* src = "<stdin>";
     char* out = DEFAULT_OUTPUT;

/* START PARSING FLAGS */
     char usedv = 0;
     char usedo = 0;
     char usedf = 0;
     char error = 0;
     int used = 1;
     while(used < argc && !error){
         if(!strcmp(argv[used], "-v")){
	     if(usedv++) error++;
	     used++;
	 } else if(!strcmp(argv[used], "-o")){
	     if(usedo++) error++;
	     if(++used < argc){
	         out = argv[used++];
	     } else {
	         error++;
             }
	 } else if(!strcmp(argv[used], "-n")){
	     if(usedo++) error++;
	     if(usedv++) error++;
	     used++;
             out="";
	 } else if(!strcmp(argv[used], "-h")){
	     printf("Format: %s [-v] [-o outputfile] [-n] [inputfile]\n",argv[0]);
	     exit(0);
	 } else {
	     if(usedf++) error++;
	     src = argv[used++];
	 }
     }
     if(error){
         fprintf(stderr,"Format:\t%s [-v] [-o outputfile] [-n] [inputfile]\n",argv[0]);
	 exit(1);
     }
/* DONE PARSING FLAGS */
/* START OPENING FILES */
     if(!strcmp(src, "<stdin>")){
         if(usedf){
	     fprintf(stderr, "Format:\t%s [-v] [-o outputfile] [-n] [inputfile]\n",argv[0]);
	     exit(1);
	 } else {
             yyin = stdin;
	 }
     } else {
         yyin = fopen(src, "r");
     }
     FILE* of;
     if(strlen(out) > 0){
         of = fopen(out, "w");
     } else {
         of = stdout;
	 usedv = 0;
     }
     if(yyin == NULL || of == NULL){
         fprintf(stderr, "Failed in opening input and output files.\n");
	 fclose(of);
	 exit(1);
     }
/* DONE OPENING FILES */
/* START LEXING */
     if(usedv) printf("C- COMPILATION: %s\n", src);
     fprintf(of, "C- COMPILATION: %s\n", src);
     do{
	  yylex();
     	  printToken(currentToken, of);
	  if(usedv) printToken(currentToken, stdout);
     } while (currentToken.cat != CAT_END);
/* DONE LEXING */
     fclose(of);
}
void printToken(Token t, FILE* of){
     switch(t.cat){
	case CAT_RWORD:
	     fprintf(of,"%d: ", lineNo);
	     fprintf(of,"reserved word: %s\n", yytext);
	     break;
	case CAT_ID:
	     fprintf(of,"%d: ", lineNo);
	     fprintf(of,"ID, name= %s\n", (char*)t.data);
	     break;
	case CAT_SPEC:
	     fprintf(of,"%d: ", lineNo);
	     fprintf(of,"special symbol: %s\n", yytext);
	     break;
	case CAT_NUM:
	     fprintf(of,"%d: ", lineNo);
	     fprintf(of,"number, value= %s\n", (char*)t.data);
	     break;
	case CAT_ERR:
	     fprintf(of,"%d: ", lineNo);
	     if(currentToken.type == SYM_ERROR){
	         fprintf(of,"ERROR: %s\n", (char*)currentToken.data);
	     } else if(currentToken.type == UNMATCHED_ERROR){
	         fprintf(of,"ERROR: */\n");
             } else {
	         fprintf(of,"ERROR: Unknown error.\n");
		 // Should not get here.
             }
	     break;
	case CAT_END:
	     if(currentToken.type == END){
	         /* Valid end state, print nothing. */
	     } else if (currentToken.type == EOF_ERROR){
	         fprintf(of,"%d: ", lineNo);
    		 fprintf(of,"ERROR: EOF in comment\n");
	     } else {
	         fprintf(of,"ERROR: Unknown end state.\n");
		 // Should not get here.
	     }
	     break;
    }
}
Token* Token_new(TokenType type, TokenCat cat, const void* data){
       Token* t = malloc(sizeof(Token));
       Token_init(t, type, cat, data);
       t->alloc = 1;
       return t;
}
void Token_init(Token* t, TokenType type, TokenCat cat, const void* data){
    t->type = type;
    t->cat = cat;
    char* end;
    if(data != NULL){
//        long l = strtol((const char*)data, &end, 10);
//	if(l == 0 && end-(const char*)data != strlen((const char*)data)){
	    t->data = malloc(strlen((const char*)data)+1);
	    strcpy((char*)t->data, (const char*)data);
//	} else {
//	    t->data = malloc(sizeof(long));
//	    *(long*)t->data = l;
//	}
    } else {
        t->data = NULL;
    }
// The sections commented in this function are part of the evaluator, not technically part of the lexer.
    t->alloc=0;
}
void Token_dest(Token* t){
    if(t->data != NULL){
        free((void*)t->data);
    }
    if(t->alloc){
	free(t);
    }
}