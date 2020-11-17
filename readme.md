# Simple regular expression parser/converter

This program reads a regular expression as a command line argument, then prints a [dot](https://linux.die.net/man/1/dot) program that draws an [NFA](https://en.wikipedia.org/wiki/Nondeterministic_finite_automaton) that recognizes strings described by the regular expression.  You can use [http://magjac.com/graphviz-visual-editor/](http://magjac.com/graphviz-visual-editor/) to view the graphs online.

I plan to extend this program at some point to include a way to convert the NFA to a DFA,
and some way to actually simulate these automata on input strings.

## Syntax of regular expression input:
`U`, `(`, `)`, `*`, `e`, and `.` are special characters: they are used to define the structure of the
regular expression. Currently, there is no way to escape characters, so a string containing these
characters will never be matched.

`e` is a regular expression that matches the empty string and nothing else.

Any string of non-special characters is a regular expression that matches that string and nothing else.

If R1 and R2 are regular expressions, then R1`U`R2 is a regular expression that matches strings
matched by either R1 or R2.

If R1 and R2 are regular expressions, then R1`.`R2 is a regular expression that matches strings
that can be split into two parts, where the first part is matched by R1 and the second part is matched by R2.

If R1 is a regular expression, then R1`*` is a regular expression that matches strings that
are a concatenation of zero or more strings matched by R1.

If R1 is a regular expression, then `(`R1`)` is a regular expression that matches the same strings
that R1 matches.

When parsing a regular expression, `.` has a higher priority then `U`.

### Examples:

`e` only matches the empty string.

`abc` matches `"abc"` and no other strings.

`abcUxyz` matches `"abc"` and `"xyz"`, but no other strings.

`(ab)*` matches the empty string, `"ab"`, `"abab"`, `"ababab"`, etc.

`aUbUa.(aUb)*.aUb.(aUb)*.b` matches strings that contain only `a` and `b`, and begin and end with the same character.
