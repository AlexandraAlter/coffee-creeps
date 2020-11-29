
.PHONY: build buildAll upload clean

src = $(shell find . -type f -name '*.coffee')
build = $(patsubst ./%.coffee, dist/%.js, $(src))

build: buildAll upload

buildAll: $(src)
	coffee -o dist -c coffee/*.coffee
	wasm-pack build --out-dir dist --target nodejs

$(build): buildAll

upload:
	grunt screeps

clean:
	rm -r dist/*.js

