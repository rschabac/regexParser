%{
open Ast
%}

%token UNION
%token LPAREN
%token RPAREN
%token STAR
%token EPSILON
%token EOF
%token <string> STR

%start <Ast.regexpr> handleEOF

%right UNION
%nonassoc STAR

%%

handleEOF:
| e = concat; EOF	{ e }

concat:
| rList = nonempty_list(regexpr) { match rList with
	| [] -> failwith "not possible"
	| [r] -> r
	| h::tl -> List.fold_left (fun a b -> Concat(a,b)) h tl
}

regexpr:
| EPSILON	{ Epsilon }
| s = STR	{ String s }
| r1 = regexpr; UNION; r2 = regexpr		{ Union(r1, r2) }
| r = regexpr; STAR		{ Star r }
| LPAREN; c = concat; RPAREN	{ c }
