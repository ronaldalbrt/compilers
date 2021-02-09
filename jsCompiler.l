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

"else if"  { yylval.c = novo + "else if";
	     return ELSE_IF; }

"else"     { yylval.c = novo + "else";
            return ELSE; }

"if"       { yylval.c = novo + "if";
	     return IF; }

"let"	   { yylval.c = novo + "let"; 
             return LET; }

">="	   { yylval.c = novo + ">=";
             return MAIG; }

"<="	   { yylval.c = novo + "<="; 
             return MEIG; }

"=="	   { yylval.c = novo + "==";
 	     return IG; }
	
"!="	   { yylval.c = novo + "!=";
	     return DIF; }

{ID}       { yylval.c = novo + yytext; 
             return ID; }

.          { yylval.c = novo + yytext;
	     return yytext[0]; }

%%
