open Ast
open Regex

let _main =
	Sys.argv.(1) |> parse |> fully_parenthesized_string_of_regexpr |> print_endline
