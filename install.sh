#!/bin/bash

pushd home
for d in */ ; do
    echo "stow ${d%/} in $HOME"
    stow -t $HOME "${d%/}"
done
popd

pushd etc
for d in */ ; do
    echo "stow ${d%/} in /etc"
    sudo stow -t /etc "${d%/}"
done
popd
