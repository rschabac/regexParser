let _main =
	Sys.argv.(1) |> Lexing.from_string |> Parser.handleEOF Lexer.read
