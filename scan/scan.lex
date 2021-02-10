%{ // Código em C/C++
#include <stdio.h>
#include <string>

using namespace std;

enum TOKEN { _ID = 256, _FOR, _IF, _INT, _FLOAT, _MAIG, _MEIG, _IG, _DIF, _STRING, _COMENTARIO};
%}

L 	[A-Za-z_$]
D	[0-9]

WS	[ \t\n]
FOR	[Ff][Oo][Rr]
IF	[Ii][Ff]
ID	{L}({L}|{D})*
INT	{D}+
FLOAT	{INT}(\.{INT})?([Ee](\+|\-)?{INT})?	
COM	(\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*\/+)|(\/\/.*)
STR	\"((\\\")|(\"\")|[^"])*\"
	
%%	
    
{WS}	{ /* ignora espaço */ }
{FOR}	{ return _FOR; }
{IF}	{ return _IF; }
{ID}	{ return _ID; }
{INT}	{ return _INT; }
{FLOAT}	{ return _FLOAT; }
">="	{ return _MAIG; }
"<="	{ return _MEIG; }
"=="	{ return _IG; }	
"!="	{ return _DIF; }
{COM}	{ return _COMENTARIO; }
{STR}	{ return _STRING; }
.	{ return yytext[0]; }
%%

int main() {
  int token = 0;
  

  while( (token = yylex()) != EOF )  
    printf( "Token: %d %s\n", token, yytext );
  
  return 0;
}
