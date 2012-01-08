
build:
	npm rebuild

develop:
	supervisor server.coffee


clean:
	find node_modules -name .gitignore -exec rm -v {} \;
