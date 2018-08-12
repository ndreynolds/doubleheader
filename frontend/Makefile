ELM_FILES := $(shell find . -name "*.elm")

assets: public/app.js public/web-components.js public/app.css

public/app.js: $(ELM_FILES)
	elm make src/Main.elm --warn --output $@

public/web-components.js: web-components/index.js
	web-components/node_modules/.bin/webpack-cli $< -o $@

public/app.css: styles/app.scss
	sassc $< $@
