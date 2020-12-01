
.PHONY: build buildAll upload clean

coffeeSrc = $(shell find . -type f -name '*.coffee')
coffeeBuild = $(patsubst ./%.coffee, dist/%.js, $(src))

nimSrc = $(shell find . -type f -name '*.nim')
nimBuild = 'dist/nim.js'

rustSrc = $(shell find . -type f -name '*.rs')
rustBuild = 'dist/rust_creeps.js'

build: buildCoffee buildNim buildRust upload

buildCoffee: $(coffeeSrc)
	coffee -o dist -c coffee/*.coffee

buildNim: $(nimSrc)
	nim js -d:nodejs -o:dist/nim.js nim/main.nim

buildRust: $(rustSrc)
	wasm-pack build --out-dir dist --target nodejs

$(coffeeBuild) $(nimBuild) $(rustBuild): buildAll

upload:
	grunt screeps

clean:
	rm -r dist/*.js

