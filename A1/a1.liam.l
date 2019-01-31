%{
	/* Declarations */
	#include <stdio.h>
	#define CAT_RWORD 0
	#define CAT_SPECIAL 1
	#define CAT_ID 2
	#define CAT_NUM 3
	#define CAT_ERROR 4
	#define CAT_END 5

	int tokenCat;
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
	void printToken(TokenType t, int c);
%}

DIGIT		[0-9]
LETTER		[a-zA-Z]
RESERVED	(bool|if|int|else|not|return|true|false|void|while)
ID		{LETTER}+
NUM		{DIGIT}+
OCOM		\/\*
CCOM		\*\/
SPECIAL		[+\-*/<>;,()\[\]{}]|[<>!=]?=|&&|\|\|
SPACE		[ \t]
NEWLINE		\r?\n
OTHER		.
%x COMMENT
%%

<INITIAL>{SPACE}	{/*Consume whitespace*/}

<INITIAL>{RESERVED}	{tokenCat = CAT_RWORD; if(!strcmp(yytext, "bool")){return BOOL;}else if (!strcmp(yytext, "if")){return IF;}else if(!strcmp(yytext, "int")){return INT;}else if(!strcmp(yytext, "else")){return ELSE;}else if(!strcmp(yytext, "not")){return NOT;}else if(!strcmp(yytext, "return")){return RETURN;}else if(!strcmp(yytext, "true")){return TRUE;}else if(!strcmp(yytext, "false")){return FALSE;}else if(!strcmp(yytext, "void")){return VOID;}else if(!strcmp(yytext,"while")){return WHILE;}else{return UNK;}}

<INITIAL>{ID}		{tokenCat = CAT_ID; return ID;}

<INITIAL>{OCOM}		    {BEGIN(COMMENT);}

<INITIAL>{CCOM}		    {tokenCat = CAT_ERROR; return UNMATCHED_ERROR;}

<INITIAL>{SPECIAL}	    {tokenCat = CAT_SPECIAL; if(!strcmp(yytext,"+")){return PLUS;}else if(!strcmp(yytext,"-")){return MINUS;}else if(!strcmp(yytext, "*")){return TIMES;}else if(!strcmp(yytext, "/")){return DIV;}else if(!strcmp(yytext, "<")){return LT;}else if(!strcmp(yytext, ">")){return GT;}else if(!strcmp(yytext, ";")){return SEMI;}else if(!strcmp(yytext, ",")){return COMMA;}else if(!strcmp(yytext, "(")){return OP;}else if(!strcmp(yytext, ")")){return CP;}else if(!strcmp(yytext, "[")){return OSB;}else if(!strcmp(yytext, "]")){return CSB;}else if(!strcmp(yytext, "{")){return OCB;}else if(!strcmp(yytext, "}")){return CCB;}else if(!strcmp(yytext, "<=")){return LTE;}else if(!strcmp(yytext, ">=")){return GTE;}else if(!strcmp(yytext, "==")){return E;}else if(!strcmp(yytext, "=")){return ASSN;}else if(!strcmp(yytext, "&&")){return LAND;}else if(!strcmp(yytext, "||")){return LOR;}else{return UNK;}}

<INITIAL>{NUM}		    {tokenCat = CAT_NUM; return NUM;}

<INITIAL,COMMENT>{NEWLINE} {lineNo++;}

<INITIAL>{OTHER}	    {tokenCat = CAT_ERROR; return SYM_ERROR;}

<INITIAL><<EOF>>	    {tokenCat = CAT_END; return END;}

<COMMENT>{CCOM}		    {BEGIN(INITIAL);}

<COMMENT><<EOF>>	    {tokenCat = CAT_END; return EOF_ERROR;}
			    
<COMMENT>{OTHER}	    {/* Consume comment contents */}
%%
void main(){
     TokenType currentToken;
     do{
          currentToken = yylex();
     	  printToken(currentToken, tokenCat);
     } while (tokenCat != CAT_END);
}
void printToken(TokenType currentToken, int tokenCat){
     printf("%d: ", lineNo);
     switch(tokenCat){
	case CAT_RWORD:
	     printf("reserved word: %s\n", yytext);
	     break;
	case CAT_ID:
	     printf("ID, name= %s\n", yytext);
	     break;
	case CAT_SPECIAL:
	     printf("special symbol: %s\n", yytext);
	     break;
	case CAT_NUM:
	     printf("number, value= %s\n", yytext);
	     break;
	case CAT_ERROR:
	     if(currentToken == SYM_ERROR){
	         printf("ERROR: %s (%d)\n", yytext, (int)(*yytext));
	     } else if(currentToken == UNMATCHED_ERROR){
	         printf("ERROR: Unmatched close comment.\n");
             } else {
	         printf("ERROR: Unknown error.\n");
		 // Should not get here.
             }
	     break;
	case CAT_END:
	     if(currentToken == END){
	         /* Valid end state, print nothing. */
	     } else if (currentToken == EOF_ERROR){
	         printf("ERROR: EOF in comment\n");
	     } else {
	         printf("ERROR: Unknown end state.\n");
		 // Should not get here.
	     }
	     break;
    }
}