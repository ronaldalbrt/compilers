DELIM   [\t\n ]
DIGITO  [0-9]
LETRA   [A-Za-z_]
DOUBLE  {DIGITO}+("."{DIGITO}+)?
ID      {LETRA}({LETRA}|{DIGITO})*
STR 	(\"([^\"\n]|(\\\")|\"\")+\")|(\'([^\"\n]|(\\\")|\"\")+\')
%%

{DELIM}    { }

             
{DOUBLE}   { yylval.c = novo + yytext; 
             return NUM; }

{STR}	   { yylval.c = novo + yytext;
             return STR; }
"if"       { yylval.c = novo + "erro";
	     return IF; }

"let"	   { yylval.c = novo + "erro"; 
             return LET; }

{ID}       { yylval.c = novo + yytext; 
             return ID; }

.          { yylval.c = novo + yytext;
	     return yytext[0]; }

%%
