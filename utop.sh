#!/usr/bin/env bash
#workaround to start utop with the correct modules

#I was using WSL when making this, so this just copies the utop directives to the windows clipboard
utop_init=$(cat <<INIT
#mod_use "_build/default/src/ast.ml";;\n
#mod_use "_build/default/src/parser.ml";;\n
#mod_use "_build/default/src/lexer.ml";;\n
#mod_use "_build/default/src/regex.ml";;\n
open Regex;;
INIT
)
echo -e $utop_init | '/mnt/c/windows/system32/clip.exe'
exec utop
