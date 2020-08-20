type regexpr =
| Epsilon
| String of string
| Union of regexpr * regexpr
| Concat of regexpr * regexpr
| Star of regexpr
