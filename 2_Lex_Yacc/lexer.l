%{
#include "parser.tab.h"
#include <stdlib.h>
void yyerror(const char *s);
%}

%%

"int"        return INT;
"main"       return MAIN;
"return"     return RETURN;
"if"         return IF;
"else"       return ELSE;
"while"      return WHILE;
"struct"     return STRUCT;
"cin"        return CIN;
"cout"       return COUT;
"bool"       return BOOL;
"char"       return CHAR;
"string"     return STRING;
"double"     return DOUBLE;


[0-9]+       { yylval = atoi(yytext); return INT_CONST; }
\"[^\"]*\"   { return STRING_LITERAL; }

[a-zA-Z_][a-zA-Z0-9_]* return IDENTIFIER;

"{"          return LBRACE;
"}"          return RBRACE;
"("          return LPAREN;
")"          return RPAREN;
"=="         return EQ;
"!="         return NEQ;
"<="         return LTE;
">="         return GTE;
"<"          return LT;
">"          return GT;
"="          return ASSIGN;
";"          return SEMICOLON;
"+"          return PLUS;
"-"          return MINUS;
"*"          return MUL;
"/"          return DIV;
"%"          return MOD;
">>"         return RSHIFT;
"<<"         return LSHIFT;

[ \t\n]+     ; /* Ignore whitespace */

.            { yyerror("Unexpected character"); }

%%

int yywrap() {
    return 1;
}
