%{
    #include <stdio.h>
    #include <string.h>

    int yycolumn = 1;  
    int symbolIndex = 0;  
    FILE* stFile;
    FILE* pifFile;

    void addSymbol(const char* name, const char* type);
    int getSymbolIndex(const char* name);
    void reportLexicalError(const char* errorType, const char* token, int line, int column);
%}

%option noyywrap

%%

"int"|"if"|"else"|"while"|"do"|"bool"|"char"|"cin"|"cout"|"main"|"double"|"string"|"struct"|"endl"|"return" {
    fprintf(pifFile, "%s : 0\n", yytext);
    yycolumn += yyleng;
}

"true"|"false" {
    int index = getSymbolIndex(yytext);
    if (index == -1) {
        symbolIndex++;
        addSymbol(yytext, "CONST");
        index = symbolIndex;
    }
    fprintf(pifFile, "CONST : %d\n", index);
    yycolumn += yyleng;
}

[A-Za-z_][A-Za-z0-9_]* {
    int index = getSymbolIndex(yytext);
    if (index == -1) {
        symbolIndex++;
        addSymbol(yytext, "ID");
        index = symbolIndex;
    }
    fprintf(pifFile, "ID : %d\n", index);
    yycolumn += yyleng;
}

[0-9]+ {
    int index = getSymbolIndex(yytext);
    if (index == -1) {
        symbolIndex++;
        addSymbol(yytext, "CONST");
        index = symbolIndex;
    }
    fprintf(pifFile, "CONST : %d\n", index);
    yycolumn += yyleng;
}

\'[^\']\' {
    int index = getSymbolIndex(yytext);
    if (index == -1) {
        symbolIndex++;
        addSymbol(yytext, "CONST");
        index = symbolIndex;
    }
    fprintf(pifFile, "CONST : %d\n", index);
    yycolumn += yyleng;
}

\"([^\"\\]|\\.)*\" {
    int index = getSymbolIndex(yytext);
    if (index == -1) {
        symbolIndex++;
        addSymbol(yytext, "CONST");
        index = symbolIndex;
    }
    fprintf(pifFile, "CONST : %d\n", index);
    yycolumn += yyleng;
}

"<<"|">>"|"+"|"-"|"*"|"/"|"%"|"=" {
    fprintf(pifFile, "%s : 0\n", yytext);
    yycolumn += yyleng;
}

"<="|">="|"=="|"!="|"<"|">" {
    fprintf(pifFile, "%s : 0\n", yytext);
    yycolumn += yyleng;
}

"["|"]"|"{"|"}"|","|":"|";"|"("|")" {
    fprintf(pifFile, "%s : 0\n", yytext);
    yycolumn += yyleng;
}

[ \t]+ {
    yycolumn += yyleng;
}

\n {
    yylineno++;
    yycolumn = 1;
}

"//".* {
    yylineno++;
    yycolumn = 1;
}

. {
    reportLexicalError("Invalid character", yytext, yylineno, yycolumn);
    yycolumn += yyleng;
}

%%

void addSymbol(const char* name, const char* type) {
    fprintf(stFile, "%d: %s\n", symbolIndex, name);
}

int getSymbolIndex(const char* name) {
    char buffer[256];
    rewind(stFile);
    while (fgets(buffer, sizeof(buffer), stFile)) {
        char sym[100];
        int index;
        sscanf(buffer, "%d: %s", &index, sym);
        if (strcmp(sym, name) == 0) {
            return index;
        }
    }
    return -1;
}

void reportLexicalError(const char* errorType, const char* token, int line, int column) {
    fprintf(stderr, "Lexical Error at line %d, column %d: %s - '%s'\n", line, column, errorType, token);
}

int main(void) {
    FILE* inputFile = fopen("prime_numbers_problem.txt", "r");
    if (!inputFile) {
        printf("Error opening file\n");
        return 1;
    }

    yyin = inputFile;

    stFile = fopen("ST.out", "w+");
    if (!stFile) {
        printf("Error opening Symbol Table output file\n");
        return 1;
    }

    pifFile = fopen("PIF.out", "w");
    if (!pifFile) {
        printf("Error opening PIF output file\n");
        return 1;
    }

    yylex();

    fclose(inputFile);
    fclose(stFile);
    fclose(pifFile);

    return 0;
}


