%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <vector>
#include <map>
#include <algorithm>
#include <cstring>
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
vector<string> tokeniza( string s );
string trim( string s, string c );
vector<string> trata_param_default( vector<string> id, vector<string> default_param );
void imprime( vector<string> s);
void imprimeErro( vector<string> s);

vector<string> novo;
vector<string> zero = novo + "0";
vector<string> funcoes;
map<string, int> variaveis_declaradas;

int linha = 1;
int coluna = 1;
int param_counter = 0;
int array_decl_counter = 0;
int param_decl_counter = 0;
%}

%token NUM ID LET STR IF WHILE FOR ELSE ELSE_IF MAIG MEIG IG DIF ASM FUNCTION RETURN SETA TRUE FALSE ABRE_PAR_SETA

%right ','

%start S

%%
S : CMDs { $$.c = $1.c + "." + funcoes; imprime( resolve_enderecos($$.c) ); }
  ;

CMDs : CMD CMDs { $$.c = $1.c + $2.c; } 
     | { $$.c = novo; }
     ;

CMD : ATR ';'{ $$.c = $1.c + "^"; }
    | LET DECLVARs ';' 
    { $$ = $2; }
    | IF '(' R ')' B  C
    { string endif = gera_label( "end_if" );
      string then = gera_label("then");

     $$.c = $3.c + then + "?" + $6.c + endif + "#" + (":" + then) + $5.c + (":" + endif); }
    | WHILE '(' R ')' B
    { string endwhile = gera_label("end_while"); 
      string startwhile = gera_label("start_while");
      $$.c = $3.c + "!" + endwhile + "?" + (":" + startwhile) + $5.c + $3.c + startwhile + "?" + (":" + endwhile); }
    | FOR '(' CMD  R ';' ATR ')' B
    { string endfor = gera_label("end_for"); 
      string startfor = gera_label("start_for");
      $$.c = $3.c + $4.c + "!" + endfor + "?" + (":" + startfor) + $8.c + $6.c + "^" + $4.c + startfor + "?" + (":" + endfor); }
    | E ASM ';' { $$.c = $1.c + $2.c + "^"; }
    | FUNCTION ID '(' FUNC_DECL_PARAMs ')' B 
    { string endfunc = gera_label("end_func");
      $$.c = $2.c + "&" + $2.c + "{}" + "=" + "'&funcao'" + endfunc + "[=]" + "^";
      funcoes = funcoes + (":" + endfunc) + $4.c + $6.c + "undefined" + "@" + "'&retorno'" + "@" + "~"; }
    | RETURN ATR ';' { $$.c = $2.c + "'&retorno'" + "@" + "~"; }  
    ;

FUNC_DECL_PARAMs: ID ',' FUNC_DECL_PARAMs { $$.c = $1.c + "&" + $1.c + "arguments" + "@" + ":arguments:" + "[@]" + "=" + "^" + $3.c; }
                | ID { $$.c = $1.c + "&" + $1.c + "arguments" + "@" + ":arguments:" + "[@]" + "=" + "^"; }
                | ID '=' ATR { $$.c = trata_param_default( $1.c, $3.c ); }
                | ID '=' ATR ',' FUNC_DECL_PARAMs { $$.c = trata_param_default( $1.c, $3.c ) + $5.c; }
                | { $$.c = novo; }
                ;

B : '{' CMDs '}' { $$.c = $2.c; }
  | CMD	         { $$.c = $1.c; }
  | B_VAZIO  	 { $$.c = $1.c; }
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

DECLVAR : ID '=' ATR	
	{ //string var = $1.c[0];
	  //if( variaveis_declaradas.find(var) == variaveis_declaradas.end() ){
		 $$.c = $1.c + "&" + $1.c + $3.c + "=" + "^";
		//variaveis_declaradas[var] = linha;
	  //}
	  //else{
		//imprimeErro(novo + "Erro: a variável \'"+ $1.c + "\' já foi declarada na linha " + to_string(variaveis_declaradas[var]) + ".");
		//exit(1);
	  //}
 }
        | ID       
	{ //string var = $1.c[0];
	  //if( variaveis_declaradas.find(var) == variaveis_declaradas.end() ){
	  	$$.c = $1.c + "&";
		//variaveis_declaradas[var] = linha;
	  //}
	  //else { 
		//imprimeErro(novo + "Erro: a variável \'" + $1.c + "\' já foi declarada na linha " + to_string(variaveis_declaradas[var]) + ".");
		//exit(1);
          //}
 }
        ;

FUNC: ID '(' FUNC_PARAMs ')' { $$.c = $3.c + to_string(param_counter) + $1.c + "@"; }
    | PROP '(' FUNC_PARAMs ')' { $$.c = $3.c + to_string(param_counter) + $1.c + "[@]"; }
    ;

FUNC_PARAMs: ATR ',' FUNC_PARAMs { $$.c = $1.c + $3.c; param_counter++; }
	   | ATR { $$.c = $1.c; param_counter++; }
	   | { $$.c = novo; }
           ; 

PROP: PROP_NAME '[' ATR ']' { $$.c = $1.c + $3.c; }
    | PROP_NAME '.' ID    { $$.c = $1.c + $3.c; }
    ;

PROP_NAME: ID { $$.c = $1.c + "@"; }
	 | PROP { $$.c = $1.c + "[@]"; }
	 ;


SETA_FUNC: SETA_FUNC_PARAMs SETA B_SETA
     	   { string endsetafunc = gera_label("end_setafunc"); 
             $$.c = novo + "{}" + "'&funcao'" + endsetafunc + "[<=]";
             funcoes = funcoes + (":" + endsetafunc) + $1.c + $3.c; }
	 ;

SETA_FUNC_PARAMs: ABRE_PAR_SETA SETA_PARAMs ')' { $$.c = $2.c; }
		| ID  { $$.c = $1.c + "&" + $1.c + "arguments" + "@" + ":arguments:" + "[@]" + "=" + "^"; }
                | '(' ')' { $$.c = novo; }
		;

SETA_PARAMs: SETA_PARAMs ',' ID  { $$.c = $1.c + $3.c + "&" + $3.c + "arguments" + "@" + ":arguments:" + "[@]" + "=" + "^"; }
	      | ID { $$.c = $1.c + "&" + $1.c + "arguments" + "@" + ":arguments:" + "[@]" + "=" + "^";  }
	      ;

B_SETA : '{' CMDs '}' { $$.c = $2.c + "undefined" + "@" + "'&retorno'" + "@" + "~"; }
       | ATR { $$.c = $1.c + "'&retorno'" + "@" + "~"; }
       ;

ATR : ID '=' ATR   
    { //string var = $1.c[0];
      //if( variaveis_declaradas.find(var) != variaveis_declaradas.end() ){
   	 $$.c = $1.c + $3.c + "="; 
    // }
    //  else {
	//imprimeErro(novo + "Erro: a variável \'" + $1.c + "\' não foi declarada.");
	//exit(1);
      //} 
}
    | PROP '=' ATR 	{ $$.c = $1.c + $3.c + "[=]"; }
    | SETA_FUNC   { $$.c = $1.c;}
    | FUNCTION_RETURN {$$.c = $1.c; }
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

E : E '+' M { $$.c = $1.c + $3.c + "+"; }
  | E '-' M { $$.c = $1.c + $3.c + "-"; }
  | M
  ;

M: M '%' T { $$.c = $1.c + $3.c + "%"; }
 | T 
 ;

T : T '*' F { $$.c = $1.c + $3.c + "*"; }
  | T '/' F { $$.c = $1.c + $3.c + "/"; }
  | F
  ;

R_NUM: '-' NUM { $$.c = zero + $2.c + "-"; }
     | NUM { $$.c = $1.c; }

F : ID          { $$.c = $1.c + "@"; }
  | PROP 	{ $$.c = $1.c + "[@]"; }
  | FUNC	{ param_counter = 0; $$.c = $1.c + "$"; }
  | R_NUM       { $$.c = $1.c; }
  | STR         { $$.c = $1.c; }
  | '(' ATR ')'   { $$.c = $2.c; }
  | B_VAZIO     { $$.c = $1.c + "{}"; }
  | '[' ']'     { $$.c = novo + "[]"; }
  | ARRAY	{ array_decl_counter = 0; $$.c = $1.c; }
  | OBJ		{ $$.c = $1.c; }
  | TRUE	{ $$.c = $1.c; }
  | FALSE	{ $$.c = $1.c; }
  ;


ARRAY: '[' ARRAY_N ']' { $$.c = novo + "[]" + $2.c; }
     ;

ARRAY_N: ARRAY_N ',' ATR { $$.c = $1.c + to_string(array_decl_counter++) + $3.c + "[<=]"; }
       | ATR { $$.c = novo + to_string(array_decl_counter++) + $1.c + "[<=]"; }
       ;
OBJ: '{' OBJ_DECL '}' { $$.c = novo + "{}" + $2.c; }
   ;

OBJ_DECL: OBJ_DECL ',' ID ':' ATR { $$.c = $1.c + $3.c + $5.c + "[<=]"; }
	| ID ':' ATR { $$.c = $1.c + $3.c + "[<=]"; }
	;

B_VAZIO: '{' '}' { $$.c = novo; }
       ;

FUNCTION_RETURN: FUNCTION '(' FUNC_DECL_PARAMs ')' B 
    	       { string endfunc = gera_label("end_func");
      		 $$.c = novo + "{}" + "'&funcao'" + endfunc + "[<=]";
      		 funcoes = funcoes + (":" + endfunc) + $3.c + $5.c + "undefined" + "@" + "'&retorno'" + "@" + "~"; } 
	       ;
%%

#include "lex.yy.c"

void yyerror( const char* st ) {
   puts( st ); 
   cout << "Linha: " << linha << " | Coluna: " << coluna << endl;
   printf( "Proximo a: %s\n", yytext );
   exit( 1 );
}

void imprime( vector<string> s)
{
  for( int i = 0; i < s.size(); i++ )
  {
  	cout << s[i] << endl;
  }
}

void imprimeErro(vector<string> s)
{
  for(int i = 0; i < s.size(); i++)
  {
	cout << s[i];
  } 

  cout << endl;
}

vector<string> tokeniza( string s ) {
  vector<string> a;
  string b = "";

  for ( int i = 0; i < s.size(); i++ ) {
	if(s[i] == ' ') {
		a = a + b;
		b = "";
	}
	else {
		b.push_back(s[i]);	
  	}	
  }
  a = a + b;
  
  return a;
}

string trim( string s, string c ) {
  vector<char> a;
  for( int i = 0; i < c.size(); i++ ) {
  	a.push_back(c[i]);
  }

  for( int i = 0; i < s.size(); i++ ) {
  	if(find(a.begin(), a.end(), s[i]) != a.end()) {
        	s[i] = ' ';
                for(int j = i; j < s.size(); j++) {
                	s[j] = s[j + 1];
        	}
		s.pop_back();
        }
  }
  return s;
}

vector<string> trata_param_default( vector<string> id, vector<string> default_param ) {
  vector<string> ret{ "undefined" };
  string then = gera_label( "then" );
  string end_if = gera_label( "end_if" );

  ret = ret + "@" + "arguments" + "@" + ":arguments:" + "[@]" + "==" + then + "?" 
  + id + "&" + id + "arguments" + "@" + ":arguments_:"+ "[@]" + "=" + "^" + end_if + "#"
  + (":" + then) + id + "&" + id + default_param + "=" + "^" + (":" + end_if); 

  return ret;
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
  int indice_args = 0;

  for( int i = 0; i < entrada.size(); i++ ) 
    if( entrada[i][0] == ':' ) {
      if( entrada[i].substr(1,9) == "arguments" ) {
        if( entrada[i][10] == '_' ) 
          saida.push_back( std::to_string(indice_args-1) );
        else {
          saida.push_back( std::to_string(indice_args) );
          ++indice_args;
        }
      } else {
        label[entrada[i].substr(1)] = saida.size();
      }
    } else if (entrada[i] == "'&retorno'") {
      indice_args = 0;
      saida.push_back( entrada[i] );
    } else {
      saida.push_back( entrada[i] );
    }      
  
  for( int i = 0; i < saida.size(); i++ ) 
    if( label.count( saida[i] ) > 0 )
        saida[i] = to_string(label[saida[i]]);
    
  return saida;
}

int main( int argc, char* argv[] ) { 
  yyparse();
  
  return 0;
}
