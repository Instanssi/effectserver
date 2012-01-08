
build:
	find node_modules -name .gitignore -exec rm -v {} \;
	npm rebuild
