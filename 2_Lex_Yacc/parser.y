%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern int yydebug; // Declaration of yydebug

void yyerror(const char *s);

// We'll track which productions are used
int productions_used[1000];
int prod_count = 0;

// A macro to record a production number
#define RECORD_PRODUCTION(num) \
    do { \
        productions_used[prod_count++] = (num); \
    } while (0)
%}

/* Tokens */
%token IDENTIFIER INT_CONST
%token PLUS MINUS MUL DIV MOD ASSIGN CIN COUT IF ELSE WHILE STRUCT INT MAIN RETURN SEMICOLON
%token LBRACE RBRACE LPAREN RPAREN GT LT GTE LTE EQ NEQ
%token BOOL CHAR STRING DOUBLE
%token RSHIFT LSHIFT
%token STRING_LITERAL


/* Precedence and associativity */
%left PLUS MINUS
%left MUL DIV MOD
%nonassoc LT LTE GT GTE EQ NEQ
%nonassoc ELSE

%%
/* Production numbering and comments: */

/* 1: program -> INT MAIN ( ) { stmt_list final_return } */
program: INT MAIN LPAREN RPAREN LBRACE stmt_list final_return RBRACE
        { RECORD_PRODUCTION(1); 
          printf("Program syntactic correct\n"); 
          printf("Productions used: ");
          for (int i = 0; i < prod_count; i++) {
              printf("%d ", productions_used[i]);
          }
          printf("\n");
        }
;

/* 2: final_return -> RETURN INT_CONST SEMICOLON */
final_return: RETURN INT_CONST SEMICOLON
            { RECORD_PRODUCTION(2); }
;

/* 3: stmt_list -> stmt_list stmt | ε (empty) */
stmt_list:
    /* empty */
  | stmt_list stmt
    { RECORD_PRODUCTION(3); }
;

/* 4: stmt -> stmt_simple SEMICOLON 
   5: stmt -> stmt_struct SEMICOLON 
   6: stmt -> stmt_cmpd 
   7: stmt -> stmt_if 
   8: stmt -> stmt_while */
stmt: stmt_simple SEMICOLON
    { RECORD_PRODUCTION(4); }
  | stmt_struct SEMICOLON
    { RECORD_PRODUCTION(5); }
  | stmt_cmpd
    { RECORD_PRODUCTION(6); }
  | stmt_if
    { RECORD_PRODUCTION(7); }
  | stmt_while
    { RECORD_PRODUCTION(8); }
;

/* 9:  stmt_simple -> stmt_assign
   10: stmt_simple -> stmt_io
   11: stmt_simple -> DataType IDENTIFIER */
stmt_simple: stmt_assign
           { RECORD_PRODUCTION(9); }
         | stmt_io
           { RECORD_PRODUCTION(10); }
         | DataType IDENTIFIER
           { RECORD_PRODUCTION(11); }
;

/* 12: stmt_assign -> IDENTIFIER = expression */
stmt_assign: IDENTIFIER ASSIGN expression
    { RECORD_PRODUCTION(12); }
;

/* 13: stmt_io -> CIN >> IDENTIFIER
   14: stmt_io -> COUT << printable_list */
stmt_io: CIN RSHIFT IDENTIFIER
       { RECORD_PRODUCTION(13); }
     | COUT LSHIFT printable_list
       { RECORD_PRODUCTION(14); }
;

/* 15: printable_list -> factor
   16: printable_list -> factor << printable_list */
printable_list: factor
              { RECORD_PRODUCTION(15); }
              | factor LSHIFT printable_list
              { RECORD_PRODUCTION(16); }
;

/* factor can be:
   17: ( expression )
   18: IDENTIFIER
   19: INT_CONST
   20: STRING_LITERAL */
factor: LPAREN expression RPAREN
      { RECORD_PRODUCTION(17); }
      | IDENTIFIER
      { RECORD_PRODUCTION(18); }
      | INT_CONST
      { RECORD_PRODUCTION(19); }
      | STRING_LITERAL
      { RECORD_PRODUCTION(20); }
;

/* 21: stmt_struct -> struct_decl */
stmt_struct: struct_decl
    { RECORD_PRODUCTION(21); }
;

/* 22: stmt_cmpd -> { stmt_list } */
stmt_cmpd: LBRACE stmt_list RBRACE
    { RECORD_PRODUCTION(22); }
;

/* IF statements:
   23: IF ( condition ) stmt
   24: IF ( condition ) stmt ELSE stmt */
stmt_if: IF LPAREN condition RPAREN stmt %prec ELSE
       { RECORD_PRODUCTION(23); }
       | IF LPAREN condition RPAREN stmt ELSE stmt
       { RECORD_PRODUCTION(24); }
;

/* 25: stmt_while -> WHILE ( condition ) stmt */
stmt_while: WHILE LPAREN condition RPAREN stmt
    { RECORD_PRODUCTION(25); }
;

/* Struct declaration:
   26: struct_decl -> STRUCT IDENTIFIER { member_list } */
struct_decl: STRUCT IDENTIFIER LBRACE member_list RBRACE
    { RECORD_PRODUCTION(26); }
;

/* Member lists inside struct:
   27: member_list -> member_decl ; member_list
   28: member_list -> ε */
member_list: member_decl SEMICOLON member_list
           { RECORD_PRODUCTION(27); }
           | /* empty */
           { RECORD_PRODUCTION(28); }
;

/* 29: member_decl -> DataType IDENTIFIER */
member_decl: DataType IDENTIFIER
    { RECORD_PRODUCTION(29); }
;

/* DataType:
   30: INT
   31: BOOL
   32: CHAR
   33: STRING
   34: DOUBLE
   35: STRUCT IDENTIFIER */
DataType: INT
        { RECORD_PRODUCTION(30); }
        | BOOL
        { RECORD_PRODUCTION(31); }
        | CHAR
        { RECORD_PRODUCTION(32); }
        | STRING
        { RECORD_PRODUCTION(33); }
        | DOUBLE
        { RECORD_PRODUCTION(34); }
        | STRUCT IDENTIFIER
        { RECORD_PRODUCTION(35); }
;

/* Condition:
   36: condition -> expression
   37: condition -> expression rel_op expression */
condition: expression
         { RECORD_PRODUCTION(36); }
         | expression rel_op expression
         { RECORD_PRODUCTION(37); }
;

/* rel_op:
   38: <
   39: <=
   40: >
   41: >=
   42: ==
   43: != */
rel_op: LT
      { RECORD_PRODUCTION(38); }
      | LTE
      { RECORD_PRODUCTION(39); }
      | GT
      { RECORD_PRODUCTION(40); }
      | GTE
      { RECORD_PRODUCTION(41); }
      | EQ
      { RECORD_PRODUCTION(42); }
      | NEQ
      { RECORD_PRODUCTION(43); }
;

/* expression -> term expression_tail
   44: expression -> term expression_tail */
expression: term expression_tail
    { RECORD_PRODUCTION(44); }
;

/* expression_tail:
   45: + term expression_tail
   46: - term expression_tail
   47: ε */
expression_tail: PLUS term expression_tail
               { RECORD_PRODUCTION(45); }
               | MINUS term expression_tail
               { RECORD_PRODUCTION(46); }
               | /* empty */
               { RECORD_PRODUCTION(47); }
;

/* term -> factor term_tail
   48: term -> factor term_tail */
term: factor term_tail
    { RECORD_PRODUCTION(48); }
;

/* term_tail:
   49: * factor term_tail
   50: / factor term_tail
   51: % factor term_tail
   52: ε */
term_tail: MUL factor term_tail
         { RECORD_PRODUCTION(49); }
         | DIV factor term_tail
         { RECORD_PRODUCTION(50); }
         | MOD factor term_tail
         { RECORD_PRODUCTION(51); }
         | /* empty */
         { RECORD_PRODUCTION(52); }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
    if (prod_count > 0) {
        // The last used production before error
        int last_prod = productions_used[prod_count - 1];
        printf("Error at production %d\n", last_prod);
    } else {
        printf("Error before any production was reduced.\n");
    }
    exit(1);
}

int main(int argc, char **argv) {
    yydebug = 0; 
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("fopen");
            return 1;
        }
    } else {
        yyin = stdin;
    }

    if (yyparse() == 0) {
        // "Program syntactic correct" already printed in the program rule
    } else {
        // On error, yyerror is called
    }
    return 0;
}