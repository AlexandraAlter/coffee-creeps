#!/bin/bash

TERM=tmux

_script="$(readlink -f ${BASH_SOURCE[0]})"
_base="$(dirname $_script)"

pushd $_base

if [[ -z $1 ]]; then
	env="default"
else
	env="$1"
fi
[[ ! -d "envs/$env" ]] && echo 'invalid directory given' && exit 1

pushd "envs/$env"
npx multimeter
popd

popd
