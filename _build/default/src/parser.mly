%{
open Ast
%}

%token UNION
%token LPAREN
%token RPAREN
%token STAR
%token EPSILON
%token EOF
%token DOT
%token <string> STR

%start <Ast.regexpr> handleEOF

%right UNION
%right DOT
%nonassoc STAR

%%

handleEOF:
| e = regexpr; EOF	{ e }

regexpr:
| EPSILON	{ Epsilon }
| s = STR	{ String s }
| r1 = regexpr; UNION; r2 = regexpr		{ Union(r1, r2) }
| r = regexpr; STAR		{ Star r }
| r1 = regexpr; DOT; r2 = regexpr	{ Concat(r1, r2) }
| LPAREN; r = regexpr; RPAREN	{ r }
