%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
int yylex(void);
int yyerror(const char *s);
int success = 1;
int current_data_type;
int expn_type=-1;
int temp;
int tot_count=0;
int var_count=0;
int string_or_var[20];
int new_var_count=0;
char new_var[20][30];
char var_list[20][30];
struct symbol_table{char var_name[30]; int type;}tot_list[20];
extern int lookup_in_table(char var[30]);
extern void insert_to_table(char var[30], int type);
extern int *yytext;
%}

%union
{
int data_type;
char var_name[30];
}

%token PRM1 PRM2 PRM3 END EQ COMMA DIGIT1 DIGIT2 ADD MIN MULT DIV MOD SLC MLC LT GT LE GE ET NE AND OR NOT LB RB TRUE FALSE IF ELSEIF ELSE CLN GOTO DS WHILE DO IFEND WHILEEND REPEAT UNTIL FOR FROM TO BY FOREND VAR SQUOTE DQUOTE INP OUT RET INLFUNC POINTER AT NEW LSB RSB DICT LCB RCB

%token<data_type>NUM1
%token<data_type>NUM2
%token<data_type>STRING
%token<data_type>BOOL

%type<data_type>DATA_TYPE
%type<var_name>VAR
%type<var_name>DIGIT1
%type<var_name>DIGIT2

%start prm

%%

prm : PRM1 PRM2 { printf("\n#include<stdio.h>\nint main()\n{\n"); } STATEMENTS PRM3 { printf("return 0;\n}\n"); } AFTER

AFTER : FUNC_STMT AFTER | INL_STMT AFTER | ;

STATEMENTS : STATEMENTS STATEMENT | STATEMENT

STATEMENT : DATA_TYPE VAR_LIST END
{
for(int i = 0; i < var_count - 1; i++)
{
insert_to_table(var_list[i], current_data_type);
printf("%s, ", var_list[i]);
}
insert_to_table(var_list[var_count - 1], current_data_type);
printf("%s;\n", var_list[var_count - 1]);
var_count = 0;
}
| INP LB READ_VAR_LIST RB END {
printf("scanf(\"");
for(int i = 0; i < var_count; i++) {
if((temp=lookup_in_table(var_list[i])) != -1) {
if(temp==0)
printf("%%d ");
else if(temp==1)
printf("%%f ");
else if(temp==2)
printf("%%c ");
else
printf("%%b ");
}
else
{
printf("Cannot read undeclared variable %s !", yylval.var_name);
yyerror("");
exit(0);
}
}
printf("\"");
for(int i = 0; i < var_count; i++) {
printf(",&%s", var_list[i]);
}
printf(");\n");
var_count=0;
}
| DICT LT DATA_TYPE GT VAR LB DIGIT1 RB END
{
insert_to_table($5, current_data_type);
printf("%s[%s];\n", $5, $7);
}
| DICT LT DATA_TYPE GT VAR LB DIGIT1 RB LB DIGIT1 RB END
{
insert_to_table($5, current_data_type);
printf("%s[%s][%s];\n", $5, $7, $10);
}
| VAR {
if((temp=lookup_in_table(yylval.var_name))!=-1)
printf("%s ", yylval.var_name);
else
{
printf("\n variable \"%s\" undeclared \n", yylval.var_name);
yyerror("");
exit(0);
}
}
EQ {printf("= ");} EQ_RHS END {printf(";\n");}
| PTR_STMT
| NEW_STMT
| IF_STMT ELSEIF_STMT ELSE_STMT 
| IF_STMT IFEND
| GOTO VAR CLN { printf("goto %s;\n", yylval.var_name); }
| VAR DS { printf("%s :\n", yylval.var_name); }
| WHILE_STMT WHILEEND
| REPEAT { printf("do\n{\n"); } STATEMENTS { printf("}\n"); } UNTIL LB { printf("while( "); } A_EXPN RB CLN { printf(")\n"); }
| FOR VAR FROM DIGIT1 TO DIGIT1 BY DIGIT1 CLN { printf("for( %s = %s; %s < %s; %s += %s )\n{\n", $2, $4, $2, $6, $2, $8); } STATEMENTS { printf("}\n"); } FOREND
| OUT LB OUT_STMT RB END
{
char *s;
printf("printf(\" ");
for(int i = 0; i < var_count; i++) {
if(string_or_var[i] == 1) {
s = var_list[i];
s++;
s[strlen(s)-1] = 0;
printf("%s ", s);
}
else
{
if((temp=lookup_in_table(var_list[i])) != -1)
{
if(temp==0)
printf("%%d ");
else if(temp==1)
printf("%%f ");
else if(temp==2)
printf("%%c ");
else
printf("%%b ");
}
else
{
printf("\n Cannot read undeclared variable %s ! \n", yylval.var_name);
yyerror("");
exit(0);
}
}
}
printf("\"");
for(int i = 0; i < var_count; i++)
{
if(string_or_var[i] != 1)
printf(", %s", var_list[i]);
}
printf(");\n");
var_count = 0;
}
| VAR LB { printf("%s( ", yylval.var_name); } CALL_PARA RB END { printf(");\n"); }
| SLC { printf("//%s\n", yylval.var_name + strlen(yylval.var_name) - (strlen(yylval.var_name)-2)); }
| MLC
{
yylval.var_name[strlen(yylval.var_name)-2] = '\0';
printf("/*%s*/\n", yylval.var_name + strlen(yylval.var_name) - (strlen(yylval.var_name)-2));
}


IF_STMT : IF LB { printf("if( "); } A_EXPN RB CLN { printf(")\n{\n"); } STATEMENTS { printf("}\n"); }
ELSEIF_STMT : ELSEIF_STMT ELSEIF_STMT1 | ;
ELSEIF_STMT1 : ELSEIF LB { printf("else if( "); } A_EXPN RB CLN { printf(")\n{\n"); } STATEMENTS { printf("}\n"); }
ELSE_STMT : ELSE CLN { printf("else\n{\n"); } STATEMENTS { printf("}\n"); }
WHILE_STMT : WHILE LB { printf("while( "); } A_EXPN RB CLN { printf(")\n{\n"); } STATEMENTS { printf("}\n"); }

READ_VAR_LIST : VAR {
strcpy(var_list[var_count], yylval.var_name); 
var_count++;
} COMMA READ_VAR_LIST
| VAR {
strcpy(var_list[var_count], yylval.var_name); 
var_count++;
}

DATA_TYPE : NUM1
{
$$=$1;
current_data_type=$1;
if(temp==0)
printf("int ");
}
| NUM2
{
$$=$1;
current_data_type=$1;
if(current_data_type == 1)
printf("float ");
}
| STRING
{
$$=$1;
current_data_type=$1;
if(current_data_type == 2)
printf("char ");
}
| BOOL
{
$$=$1;
current_data_type=$1;
if(current_data_type == 3)
printf("bool ");
}
| VAR
{
if(current_data_type == 4)
printf("%s ", $1);
}


VAR_LIST: VAR
{
strcpy(var_list[var_count], $1);
var_count++;
} COMMA VAR_LIST
| VAR
{
strcpy(var_list[var_count], $1);
var_count++;
}


EQ_RHS : A_EXPN | STR_EQ


A_EXPN : A_EXPN AND {printf("&& ");} A_EXPN
| A_EXPN OR {printf("|| ");} A_EXPN
| NOT LB {printf("!( ");} A_EXPN RB { printf(")"); }
| A_EXPN LT {printf("< ");} A_EXPN
| A_EXPN GT {printf("> ");} A_EXPN
| A_EXPN LE {printf("<= ");} A_EXPN
| A_EXPN GE {printf(">= ");} A_EXPN
| A_EXPN ET {printf("== ");} A_EXPN
| A_EXPN NE {printf("!= ");} A_EXPN
| A_EXPN ADD {printf("+ ");} A_EXPN
| A_EXPN MIN {printf("- ");} A_EXPN
| A_EXPN MULT {printf("* ");} A_EXPN
| A_EXPN DIV {printf("/ ");} A_EXPN
| A_EXPN MOD {printf("%% ");} A_EXPN
| END_A_EXPN


STR_EQ : LCB SQUOTE      { printf("{%s ", yylval.var_name); } STR_EQ1 RCB { printf("};\n"); }
| LCB DIGIT1             { printf("{%s ", yylval.var_name); } STR_EQ1 RCB { printf("};\n"); }
| LCB DIGIT2             { printf("{%s ", yylval.var_name); } STR_EQ1 RCB { printf("};\n"); }

STR_EQ1 : STR_EQ2 STR_EQ4

STR_EQ2 : ; | STR_EQ3

STR_EQ3 : COMMA { printf(", "); } | CLN { printf(": "); }

STR_EQ4 : SQUOTE  { printf("%s ", yylval.var_name); } STR_EQ1
| DIGIT1          { printf("%s ", yylval.var_name); } STR_EQ1
| DIGIT2          { printf("%s ", yylval.var_name); } STR_EQ1
| ;


END_A_EXPN : VAR
{
if((temp=lookup_in_table($1))!=-1)
{
printf("%s ", $1);
if(expn_type==-1)
{
expn_type=temp;
}
else if(expn_type!=temp)
{
printf("\n type mismatch in the expression \n");
yyerror("");
exit(0);
}
}
else
{
printf("\n variable \"%s\" undeclared \n", $1);
yyerror("");
exit(0);
}
}
| SQUOTE { printf("'%s' ", yylval.var_name); }
| DIGIT1 {printf("%s ", yylval.var_name);}
| DIGIT2 {printf("%s ", yylval.var_name);}
| TRUE {printf("true ");}
| FALSE {printf("false ");}


OUT_STMT : VAR {
strcpy(var_list[var_count], $1);
var_count++;
} COMMA VAR_MORE
| DQUOTE {
strcpy(var_list[var_count], yylval.var_name);
string_or_var[var_count]=1;
var_count++;
}
| VAR_MORE


VAR_MORE : VAR {
strcpy(var_list[var_count], $1);
var_count++;
}


FUNC_STMT : DATA_TYPE VAR LB { printf("%s(", yylval.var_name); } DEF_PARA RB CLN { printf(")\n{\n"); } STATEMENTS RET { printf("return "); } A_EXPN END { printf(";\n}"); }

INL_STMT : INLFUNC { printf("inline "); } FUNC_STMT


PTR_STMT : DATA_TYPE POINTER VAR EQ AT VAR COMMA { printf("*%s = & %s,", $3, $6); } PTR_STMT1 END { printf(";\n"); }
| POINTER VAR EQ DIGIT1 END { printf("*%s = %s;\n", $2, $4); }
| POINTER VAR EQ DIGIT2 END { printf("*%s = %s;\n", $2, $4); }
| POINTER VAR EQ SQUOTE END { printf("*%s = %s;\n", $2, yylval.var_name); }

PTR_STMT1 : VAR EQ AT VAR COMMA { printf(" *%s = & %s,", $1, $4); } PTR_STMT1 | VAR EQ AT VAR { printf(" *%s = & %s ", $1, $4); }


NEW_STMT: NEW { printf("typedef "); } DATA_TYPE VAR END
{
strcpy(new_var[new_var_count], yylval.var_name);
current_data_type=4;
printf("%s ;\n", new_var[new_var_count]);
new_var_count++;
}


CALL_PARA : CALL_PARA COMMA VAR  { printf(", %s ", yylval.var_name); }
| CALL_PARA COMMA DIGIT1         { printf(", %s ", yylval.var_name); }
| CALL_PARA COMMA DIGIT2         { printf(", %s ", yylval.var_name); }
| CALL_PARA COMMA SQUOTE         { printf(", %s ", yylval.var_name); }
| CALL_PARA COMMA TRUE           { printf(", true "); }
| CALL_PARA COMMA FALSE          { printf(", false "); }
| VAR                            { printf("%s ", yylval.var_name); }
| DIGIT1                         { printf("%s ", yylval.var_name); }
| DIGIT2                         { printf("%s ", yylval.var_name); }
| SQUOTE                         { printf("%s ", yylval.var_name); }
| TRUE                           { printf("true "); }
| FALSE                          { printf("false "); }
| ;


DEF_PARA : DATA_TYPE VAR COMMA { printf("%s, ", yylval.var_name); } DEF_PARA
| DATA_TYPE VAR                { printf("%s ", yylval.var_name); }
| ;


%%


int lookup_in_table(char var[30])
{
for(int i=0; i<tot_count; i++)
{
if(strcmp(tot_list[i].var_name, var)==0)
return tot_list[i].type;
}
return -1;
}

void insert_to_table(char var[30], int type)
{
if(lookup_in_table(var)==-1)
{
tot_list[tot_count].type=type;
strcpy(tot_list[tot_count].var_name, var);
tot_count++;
}
else
{
printf("\nmultiple declarations of \"%s\" variable \n", var);
yyerror("");
exit(0);
}
}

int main()
{
yyparse();
if(success) printf("\n Parsing Successful \n");
return 0;
}

int yyerror(const char *msg)
{
extern int yylineno;
printf("\n Parsing failed\nLine number: %d %s \n", yylineno++, msg);
success = 0;
return 0;
}