{
	open Parser
	exception Error of string
}

let nonSpecial = [^'U' '(' ')' '*' 'e']+

rule read = parse
| "U"	{ UNION }
| "("	{ LPAREN }
| ")"	{ RPAREN }
| "*"	{ STAR }
| "e"	{ EPSILON }
| nonSpecial	{ STR (Lexing.lexeme lexbuf) }
| eof	{ EOF }
