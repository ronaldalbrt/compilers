%{
#include <string>
#include <iostream>
#include <map>
#include <cstring>

using namespace std;

struct Atributos {
  string v;
};

#define YYSTYPE Atributos

void erro( string msg );
void Print( string st );

// protótipo para o analisador léxico (gerado pelo lex)
int yylex();
void yyerror( const char* );
int retorna( int tk );

int linha = 1;
int coluna = 1;

%}

%token NUM STR ID LET
%right '='
%left ','
%left '+' '-'
%left '*' '/'

%start CMDs
%%

CMDs : A { Print( $1.v ); } ';' CMDs 
     | 
     ;

L_VALUE_PROP: ID '[' E ']' { $$.v = $1.v + "@ " + $3.v; }
	    | ID '.' E {$$.v = $1.v + "@ " + $3.v; }
	    ;

LET_LVALUE: LET_LVALUE ',' LET_LVALUE { $$.v = $1.v + $3.v; }
      | ID '=' E {$$.v = $1.v + "& " + $1.v + " " + $3.v + "= ^ "; }
      | ID  { $$.v = $1.v + "& "; }
      ;	 

A: LET LET_LVALUE { $$.v = $2.v; }
 | E { $$.v = $1.v; }

E : ID '=' E { $$.v = $1.v + " " + $3.v + "= ^ "; }
  | L_VALUE_PROP '=' E {$$.v = $1.v + $3. v + "[=] ^ "; } 
  | E '+' E { $$.v = $1.v + $3.v + "+ " ; }
  | E '-' E { $$.v = $1.v + $3.v + "- " ; }
  | E '*' E { $$.v = $1.v + $3.v + "* " ; }
  | E '/' E { $$.v = $1.v + $3.v + "/ " ; }
  | F
  ;
  
F : ID { $$.v = $1.v + "@ "; }
  | L_VALUE_PROP { $$.v = $1.v + "[@] "; }
  | NUM { $$.v = $1.v + " "; }
  | STR { $$.v = $1.v + " "; }
  | '(' E ')' {$$.v = $2.v; }
  | ID '(' PARAM ')' { $$.v = $3.v + $1.v + "# "; }
  | '{' '}' { $$.v = "{} "; }
  | '[' ']' { $$.v = "[] "; }
  ;
  
PARAM : ARGs { $$.v = $1.v; }
      |
      ;
  
ARGs : E ',' ARGs { $$.v = $1.v + $3.v; }
     | E { $$.v = $1.v; }
     ;
  
%%

#include "lex.yy.c"

map<int,string> nome_tokens = {
  { LET, "let" },
  { STR, "string" },
  { ID, "nome de identificador" },
  { NUM, "número" }
};

string nome_token( int token ) {
  if( nome_tokens.find( token ) != nome_tokens.end() )
    return nome_tokens[token];
  else {
    string r;
    
    r = token;
    return r;
  }
}

int retorna( int tk ) {  
  yylval.v = yytext; 
  coluna += strlen( yytext ); 

  return tk;
}

void yyerror( const char* msg ) {
  cout << endl << "Erro: " << msg << endl
       << "Perto de : '" << yylval.v << "'" <<endl;
  exit( 0 );
}

void Print( string st ) {
  cout << st << " ";
}

int main() {
  yyparse();
  
  cout << endl;
   
  return 0;
}
