%{
	#include<stdio.h>
	#include<string.h>
	#include"y.tab.h"
	#include<math.h>
	extern int var_count;
%}

%%

"num"			    {yylval.data_type=0; return NUM1;}
"numb"			    {yylval.data_type=1; return NUM2;}
"string"		    {yylval.data_type=2; return STRING;}
"boo"			    {yylval.data_type=3; return BOOL;}
"dict"              {return DICT;}
"true"              {return TRUE;}
"false"             {return FALSE;}
"main function:"    {return PRM1;}
"start:"            {return PRM2;}
"stop:"             {return PRM3;}
"~~"(.)* 		    {strcpy(yylval.var_name, yytext); return SLC;}
"~*"(.*\n)*.*"*~"  	{strcpy(yylval.var_name, yytext); return MLC;}
","			        {return COMMA;}
"_"			        {return END;}
"="			        {return EQ;}
"+"                 {return ADD;}
"-"                 {return MIN;}
"*"                 { return MULT;}
"/"                 {return DIV;}
"%"                 {return MOD;}
'[^'"]*'            {strcpy(yylval.var_name, yytext); return SQUOTE;}
\"[^'"]*\"          {strcpy(yylval.var_name, yytext); return DQUOTE;}
"if"			    {return IF;}
"else if"           {return ELSEIF;}
"else"			    {return ELSE;}
"stopif:"           {return IFEND;}
":"                 {return CLN;}
"$"                 {return DS;}
"goto"			    {return GOTO;}
"while"			    {return WHILE;}
"repeat"			{return REPEAT;}
"until"             {return UNTIL;}
"stopwhile:"        {return WHILEEND;}
"for"			    {return FOR;}
"from"			    {return FROM;}
"to"			    {return TO;}
"by"			    {return BY;}
"stopfor:"          {return FOREND;}
"and"               {return AND;}
"or"                {return OR;}
"not"               {return NOT;}
"input"             {return INP;}
"print"             {return OUT;}
"return"            {return RET;}
"inline"            {return INLFUNC;}
"pointer"           {return POINTER;}
"newtype"           {return NEW;}
"@"                 {return AT;}
"<"                 {return LT;}
">"                 {return GT;}
"<="                {return LE;}
">="                {return GE;}
"=="                {return ET;}
"!="                {return NE;}
"("                 {return LB;}
")"                 {return RB;}
"["                 {return LSB;}
"]"                 {return RSB;}
"{"                 {return LCB;}
"}"                 {return RCB;}
[a-zA-Z][a-zA-Z0-9]*  	{strcpy(yylval.var_name,yytext); return VAR;}
[0-9]+ 			    {strcpy(yylval.var_name, yytext); return DIGIT1;}
[0-9]+\.[0-9]+      {strcpy(yylval.var_name, yytext); return DIGIT2;}
[\t ]+  		    {}
\n 			        {++yylineno;}
. 			{printf("invalid character sequence %s\n",yytext); exit(0);}

%%

int yywrap(void)
{
    return 1;
}
