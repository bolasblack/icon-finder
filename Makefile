.PHONY : watch build test npm bower clean

BIN=node_modules/.bin

watch : bower clean
	@$(BIN)/gulp

build : bower clean
	@$(BIN)/gulp build

publish : build
	cd public && git add -A && git commit -m "`date -R`" && git push

test :
	@if [ -z $$KARMA_BROWSERS ]; then \
		KARMA_BROWSERS=PhantomJS; \
	fi; \
	node_modules/karma/bin/karma start tests/test.unit.conf.coffee --browsers $$KARMA_BROWSERS

npm :
	@echo "Check npm package update..."
	@hash npm || (echo "Install npm first" && exit 1)
	@CHECK_FILE=package.json STATE_FOLDER=node_modules sh scripts/update_manager.sh check; \
	if [ $$? -eq 1 ]; then \
		npm install \
		&& npm update \
		&& CHECK_FILE=package.json STATE_FOLDER=node_modules sh scripts/update_manager.sh update \
		; \
	fi

bower : npm
	@echo "Check bower package update..."
	@CHECK_FILE=bower.json STATE_FOLDER=bower_components sh scripts/update_manager.sh check; \
	if [ $$? -eq 1 ]; then \
		$(BIN)/bower install \
		&& $(BIN)/bower update \
		&& CHECK_FILE=bower.json STATE_FOLDER=bower_components sh scripts/update_manager.sh update \
		; \
	fi

clean :
	@echo "Start clean public files..."
	@-rm -rf public/*

