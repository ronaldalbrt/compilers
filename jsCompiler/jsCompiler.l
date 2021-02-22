DIGITO  [0-9]
LETRA   [A-Za-z_]
DOUBLE  {DIGITO}+("."{DIGITO}+)?
ID      {LETRA}({LETRA}|{DIGITO})*
STR 	(\"([^"\n]|\\\"|\"\")*\")|('([^'\n]|''|\\')*')
%%

"\t" 	   { coluna += 4; }

" "	   { coluna++; }

"\n"	   { linha++; coluna = 1; }
             
{DOUBLE}   { yylval.c = novo + yytext; 
             return NUM; }

{STR}	   { yylval.c = novo + yytext;
             return STR; }

"asm{".*"}"  {  string lexema = trim( yytext + 3, "{}" ); 
                yylval.c = tokeniza( lexema );
                coluna += strlen( yytext ); 
                return ASM; }

"function" { yylval.c = novo + "function"; 
 	     return FUNCTION; }

"return"   { yylval.c = novo + "return";
	     return RETURN; }

"else if"  { yylval.c = novo + "else if";
	     return ELSE_IF; }

"else"     { yylval.c = novo + "else";
            return ELSE; }

"if"       { yylval.c = novo + "if";
	     return IF; }

"while"    { yylval.c = novo + "while";
             return WHILE; }

"for"      { yylval.c = novo + "for";
             return FOR; }

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
