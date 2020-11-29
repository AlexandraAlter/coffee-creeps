
.PHONY: build buildAll upload clean

src = $(shell find . -type f -name '*.coffee')
build = $(patsubst ./%.coffee, dist/%.js, $(src))

build: buildAll upload

buildAll: $(src)
	coffee -o dist -c *.coffee
	nim js -d:nodejs --out:dist/nim.js main.nim

$(build): buildAll

upload:
	grunt screeps

clean:
	rm -r dist/*.js

