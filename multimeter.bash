#!/bin/bash

TERM=tmux

_script="$(readlink -f ${BASH_SOURCE[0]})"
_base="$(dirname $_script)"

pushd $_base

[[ -z $1 ]] && echo 'no directory given' && exit 1
[[ ! -d "envs/$1" ]] && echo 'invalid directory given' && exit 1

pushd "envs/$1"
npx multimeter
popd

popd
