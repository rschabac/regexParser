MAKEFILE_DIR=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))
deriv: src/ast.ml src/regex.ml src/parser.mly src/lexer.mll src/main.ml
	cd $(MAKEFILE_DIR)src && dune build main.exe -j 16
	rm -f $(MAKEFILE_DIR)regexpr
	ln -s $(MAKEFILE_DIR)_build/default/src/main.exe $(MAKEFILE_DIR)regexpr

