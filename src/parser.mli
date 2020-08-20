
(* The type of tokens. *)

type token = 
  | UNION
  | STR of (string)
  | STAR
  | RPAREN
  | LPAREN
  | EPSILON
  | EOF

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val handleEOF: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Ast.regexpr)
