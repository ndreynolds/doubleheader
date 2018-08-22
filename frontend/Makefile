ELM_FILES := $(shell find src -name "*.elm")
ELM_MAIN := src/Main.elm

SASS_FILES := $(shell find styles -name "*.scss")
SASS_MAIN := styles/app.scss

PORT := 8000

assets: public/bundle.js public/bundle.css

public/bundle.js: $(ELM_FILES)
	elm make $(ELM_MAIN) --debug --warn --output $@

public/bundle.css: $(SASS_FILES)
	sassc $(SASS_MAIN) $@

serve: assets
	cd public && python -m SimpleHTTPServer $(PORT)

develop: assets
	fswatch -0 src/* styles/* | xargs -0 -n1 -I '{}' make &
	cd public && python -m SimpleHTTPServer $(PORT)
