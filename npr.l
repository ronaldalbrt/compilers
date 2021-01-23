%{ // Código em C/C++
#include <stdlib.h>
#include <map>
#include <vector>
#include <string>
#include <iostream>
#include <cstring>

using namespace std;

string lexema;
int token;

int getToken(int);
void A();
void B();
void E();
void E_linha();
void T();
void T_linha();
void F();
void U();
void casa( int );
enum TOKEN { _ID = 256, _FOR, _IF, _INT, _FLOAT, _MAIG, _MEIG, _IG, _DIF, _STRING, _COMENTARIO, _PRINT };
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
 
{WS}		{ /* ignora espaço */ }
"print"		{ return getToken(_PRINT); }
{FOR}		{ return getToken( _FOR); }
{IF}		{ return getToken(_IF); }
{ID}		{ return getToken(_ID); }
{INT}		{ return getToken(_INT); }
{FLOAT}		{ return getToken(_FLOAT); }
">="		{ return getToken(_MAIG); }
"<="		{ return getToken(_MEIG); }
"=="		{ return getToken(_IG); }	
"!="		{ return getToken(_DIF); }
{COM}		{ return getToken(_COMENTARIO); }
{STR}		{ return getToken(_STRING); }
.		{ return getToken(yytext[0]); }
%%

int getToken( int tk ) {  
	lexema = yytext;  

	return tk;
}

void casa( int esperado ) {
	if( token == esperado)
	{	if(token != ';')
		{
			token = yylex();
		}
	}
}

void A() {
	switch(token)
	{
		case _ID:{
  			string temp = lexema; 
  			casa( _ID ); 
			printf("%s ", temp.c_str());
			casa('='); 
			E();
			switch(token){
			case 0: printf("="); break;
			default: printf("= "); } }
		break;
		case _PRINT:{
			string temp = lexema;
			casa( _PRINT );
			E();
			switch(token){
			case 0: printf("%s # ", temp.c_str()); break;
			default: printf("%s #", temp.c_str()); } }
		break;
	}
	casa(';');
}

void E() {
      	T();
  	
	while(1){
		switch(token){
			case '+': casa('+'); T(); printf("+ "); break;
			case '-': casa('-'); T(); printf("- "); break;
			default: return;
		}
	}
}

void T(){
  	F();
  	
	while(1){
		switch(token){
			case '*': casa('*'); F(); printf("* "); break;
			case '/': casa('/'); F(); printf("/ "); break;
			default: return;
		}
	}
}

void F() {
  	switch( token ) {
    		case _ID : {
      			string temp = lexema;
      			casa( _ID ); 
			switch(token) {
				case '(': U(); printf("%s # ", temp.c_str() ); break;
				default: printf( "%s @ ", temp.c_str() ); break; } }
      		break;
    		case _INT : {
      			string temp = lexema;
      			casa( _INT ); printf("%s ", temp.c_str()); }
      		break;
		case _FLOAT: {
			string temp = lexema;
			casa(_FLOAT); printf("%s ", temp.c_str()); }
		break;
		case _STRING:{
			string temp = lexema;
			casa(_STRING); printf("%s ", temp.c_str()); }
		break;
    		case '(': 
      			casa( '(' ); E(); casa(')'); break;
    		default:
      			printf( "Operando esperado, encontrado %s", lexema.c_str() );
			exit(1);
  }
}

void U() {
	switch(token){
		case '(': {
			casa('(');
			E(); 
			while(token == ','){
				casa(',');
				E();
			}
			casa(')');}
		break;
		default: return;
	}
}

int main(){
	
	while( (token = yylex()) != EOF)
		A();
	return 0;
}





