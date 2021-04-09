init:
	git submodule update --init
	# your sources codes lays here
	mkdir -p playground/src
	touch playground/src/Playground.scala

patch:
	sed '/BEGIN-PATCH/,/END-PATCH/!d;//d' readme.md | awk '{print("(cd dependencies/" $$1 " && echo " $$2 " && curl -s -L " $$2 ".patch | git apply --index)" )}' | bash

depatch:
	git submodule foreach git reset --hard

bump:
	git submodule foreach git stash
	git submodule update --remote
	git add dependencies

bsp:
	mill -i mill.bsp.BSP/install

compile:
	mill -i __.compile

clean:
	git clean -fd