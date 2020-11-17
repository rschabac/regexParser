open Regex

let _main =
	if Array.length Sys.argv != 2
	then Printf.fprintf stderr "Usage: %s <regex>\nSee readme.md for the syntax of regex\n" Sys.argv.(0)
	else
	Sys.argv.(1) |> parse |> nfa_of_regexpr |> dot_of_nfa |> print_endline
