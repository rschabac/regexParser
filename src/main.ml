open Regex

let _main =
	Sys.argv.(1) |> parse |> nfa_of_regexpr |> dot_of_nfa |> print_endline
