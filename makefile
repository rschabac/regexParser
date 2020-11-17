#gets the directory that the makefile is located in, even if make is invoked from a different directory
MAKEFILE_DIR=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

regexpr: src/ast.ml src/regex.ml src/parser.mly src/lexer.mll src/main.ml
	#actually make the project with dune
	cd $(MAKEFILE_DIR)src && dune build main.exe -j 16
	#make a symlink to the executable in the current directory
	rm -f $(MAKEFILE_DIR)regexpr
	ln -s $(MAKEFILE_DIR)_build/default/src/main.exe $(MAKEFILE_DIR)regexpr

