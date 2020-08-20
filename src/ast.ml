type regexpr =
| Epsilon
| String of string
| Union of regexpr * regexpr
| Concat of regexpr * regexpr
| Star of regexpr

let rec string_of_regexpr r = string_of_union_term r
and string_of_union_term r = match r with
| Union(r1, r2) -> Printf.sprintf "%sU%s" (string_of_union_term r1) (string_of_union_term r2)
| _ -> string_of_concat_term r
and string_of_concat_term r = match r with
| Concat(r1, r2) -> Printf.sprintf "%s%s" (string_of_concat_term r1) (string_of_concat_term r2)
| _ -> string_of_star_term r
and string_of_star_term r = match r with
| Star r1 -> Printf.sprintf "%s*" (string_of_star_term r1)
| String s -> s
| Epsilon -> "e"
| _ -> Printf.sprintf "(%s)" (string_of_union_term r)

let rec fully_parenthesized_string_of_regexpr = function
| Epsilon -> "e"
| String s -> s
| Union(r1, r2) -> Printf.sprintf "(%s)U(%s)" (fully_parenthesized_string_of_regexpr r1) (fully_parenthesized_string_of_regexpr r2)
| Concat(r1, r2) -> Printf.sprintf "(%s)(%s)" (fully_parenthesized_string_of_regexpr r1) (fully_parenthesized_string_of_regexpr r2)
| Star r1 -> Printf.sprintf "(%s)*" (fully_parenthesized_string_of_regexpr r1)
