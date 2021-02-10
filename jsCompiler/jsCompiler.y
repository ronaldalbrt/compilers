%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <vector>
#include <map>

using namespace std;

struct Atributos {
 vector<string> c;
};

#define YYSTYPE Atributos

int yylex();
int yyparse();
void yyerror(const char *);

vector<string> concatena( vector<string> a, vector<string> b );
vector<string> operator+( vector<string> a, vector<string> b );
vector<string> operator+( vector<string> a, string b );

string gera_label( string prefixo );
vector<string> resolve_enderecos( vector<string> entrada );
void imprime( vector<string> s);

vector<string> novo;
vector<string> zero = novo + "0";
%}

%token NUM ID LET STR IF WHILE FOR ELSE ELSE_IF MAIG MEIG IG DIF
// Start indica o símbolo inicial da gramática
%start S

%%
S : CMDs { imprime( resolve_enderecos($1.c) ); }
  ;

CMDs : CMD CMDs { $$.c = $1.c + $2.c; } 
     | { $$.c = novo; }
     ;

CMD : ATR ';'{ $$.c = $1.c + "^"; }
    | LET DECLVARs ';' { $$ = $2; }
    | IF '(' R ')' B  C
    { string endif = gera_label( "end_if" );	   
     $$.c = $3.c + "!" + endif + "?" + $5.c + (":" + endif) + $6.c; }
    | WHILE '(' R ')' B
    { string endwhile = gera_label("end_while"); 
      string startwhile = gera_label("start_while");
      $$.c = $3.c + "!" + endwhile + "?" + (":" + startwhile) + $5.c + $3.c + startwhile + "?" + (":" + endwhile); }
    | FOR '(' CMD  R ';' ATR ')' B
    { string endfor = gera_label("end_for"); 
      string startfor = gera_label("start_for");
      $$.c = $3.c + $4.c + "!" + endfor + "?" + (":" + startfor) + $8.c + $6.c + "^" + $4.c + startfor + "?" + (":" + endfor); }
    ;

B : '{' CMDs '}' { $$.c = $2.c; }
  | CMD 	 { $$.c = $1.c; }
  ;

C : ELSE_IF '(' R ')' B C
    { string endelseif = gera_label("end_elseif");
      $$.c = $3.c + "!" + endelseif + "?" + $5.c + (":" + endelseif); }
  | ELSE B { $$.c = $2.c; }
  | { $$.c = novo; } 
  ;

DECLVARs : DECLVAR ',' DECLVARs { $$.c = $1.c + $3.c; }
	 | DECLVAR 		{ $$ = $1; }
         ;

DECLVAR : ID '=' R { $$.c = $1.c + "&" + $1.c + $3.c + "=" + "^"; }
        | ID       { $$.c = $1.c + "&"; }
        ;

PROP: PROP_NAME '[' ATR ']' { $$.c = $1.c + $3.c; }
    | PROP_NAME '.' ID    { $$.c = $1.c + $3.c; }
    ;

PROP_NAME: ID { $$.c = $1.c + "@"; }
	 | PROP { $$.c = $1.c + "[@]"; }
	 ;

ATR : ID '=' ATR   { $$.c = $1.c + $3.c + "="; }
    | PROP '=' ATR { $$.c = $1.c + $3.c + "[=]"; }
    | R
    ;

R : E '<' E 	{ $$.c = $1.c + $3.c + "<"; }
  | E '>' E 	{ $$.c = $1.c + $3.c + ">"; }
  | E MAIG E 	{ $$.c = $1.c + $3.c + ">="; }
  | E MEIG E	{ $$.c = $1.c + $3.c + "<="; }
  | E IG E 	{ $$.c = $1.c + $3.c + "=="; }
  | E DIF E 	{ $$.c = $1.c + $3.c + "!="; } 
  | E
  ;

E : E '+' T { $$.c = $1.c + $3.c + "+"; }
  | E '-' T { $$.c = $1.c + $3.c + "-"; }
  | T
  ;

T : T '*' F { $$.c = $1.c + $3.c + "*"; }
  | T '/' F { $$.c = $1.c + $3.c + "/"; }
  | F

R_NUM: '-' NUM { $$.c = zero + $2.c + "-"; }
     | NUM { $$.c = $1.c; }

F : ID          { $$.c = $1.c + "@"; }
  | PROP 	{ $$.c = $1.c + "[@]"; }
  | R_NUM       { $$.c = $1.c; }
  | STR         { $$.c = $1.c; }
  | '(' E ')'   { $$ = $2; }
  | '{' '}'     { $$.c = novo + "{}"; }
  | '[' ']'     { $$.c = novo + "[]"; }
  ;
%%

#include "lex.yy.c"

void yyerror( const char* st ) {
   puts( st ); 
   printf( "Proximo a: %s\n", yytext );
   exit( 1 );
}

void imprime( vector<string> s)
{
  for( int i = 0; i < s.size(); i++ )
  {
  	cout << s[i] << endl;
  }

  cout << '.' << endl;
}

vector<string> concatena( vector<string> a, vector<string> b ) {
  a.insert( a.end(), b.begin(), b.end() );
  return a;
}

vector<string> operator+( vector<string> a, vector<string> b ) {
  return concatena( a, b );
}

vector<string> operator+( vector<string> a, string b ) {
  a.push_back( b );
  return a;
}

string gera_label( string prefixo ) {
  static int n = 0;
  return prefixo + "_" + to_string( ++n ) + ":";
}

vector<string> resolve_enderecos( vector<string> entrada ) {
  map<string,int> label;
  vector<string> saida;
  for( int i = 0; i < entrada.size(); i++ ) 
    if( entrada[i][0] == ':' ) 
        label[entrada[i].substr(1)] = saida.size();
    else
      saida.push_back( entrada[i] );
  
  for( int i = 0; i < saida.size(); i++ ) 
    if( label.count( saida[i] ) > 0 )
        saida[i] = to_string(label[saida[i]]);
    
  return saida;
}

int main( int argc, char* argv[] ) {
  yyparse();
  
  return 0;
}
