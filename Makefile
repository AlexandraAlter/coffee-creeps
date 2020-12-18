.PHONY: build buildAll upload clean

tsSrc = $(shell find . -type f -name '*.ts')
tsBuild = $(patsubst ./%.ts, dist/%.js, $(src))

rustSrc = $(shell find . -type f -name '*.rs')
rustBuild = 'dist/rust_creeps.wasm'

all: build copy upload

build: buildRust buildTs

buildRust: $(rustSrc)
	cargo web build --runtime standalone --release
	cp target/wasm32-unknown-unknown/release/rust_creeps.wasm dist/rust_creeps.wasm

buildTs: $(tsSrc)
	npx tsc

copy: copyJs

copyJs dist/lodash4.js:
	cp node_modules/lodash/lodash.min.js dist/lodash4.js

$(tsBuild) $(rustBuild): buildAll

upload:
ifndef env
	@echo 'no env defined'
	grunt screeps --env=default
else
	grunt screeps --env=$(env)
endif

clean:
	rm -r dist/*
