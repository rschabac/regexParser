


let lex s = Lexing.from_string s |> Lexer.read
let parse s = Lexing.from_string s |> Parser.handleEOF Lexer.read
