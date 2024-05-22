#!/bin/bash

for d in */ ; do
    echo "${d%/}"
    stow "${d%/}"
done

