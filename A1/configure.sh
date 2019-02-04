#!/bin/bash
if [ ! -w . ]; then
    echo "This script needs write permission in the current directory."
    exit 1
fi

echo """lexer:
	flex a1.flex
	gcc -o scanner lex.yy.c -lfl

test: lexer""" > Makefile
if [ ! -z `command -v perl` ]; then
    if [ -f ./__nums__ ]; then
	echo "Warning: Removing __nums__"
    fi
    ls test*.cm | perl -n -e '/test([0-9]+).cm/ && print $1."\n"' >./__nums__
    while read p; do
	echo -n -e "\t" >> Makefile
	printf $'./scanner test%s.cm -o out%s.res\n' "$p" "$p" >> Makefile
    done<__nums__
    rm ./__nums__
    echo "" >> Makefile
else
    echo -e "Requires perl to autorun tests. You can run tests manually using the following command:\n\t./scanner [testfile] [-o outputfile]"
    echo -e "\t@echo \"\033[1;31mCould not autogenerate tests. Run ./scanner -h to see command usage.\033[0m\"" >> Makefile
fi

echo -e """clean_lexer:
\trm -f lex.yy.c scanner

clean_test:
\trm -f *.res

clean: clean_lexer clean_test

deep_clean: clean
\trm Makefile
""" >> Makefile
