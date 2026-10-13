#!/bin/bash
set -exo pipefail

CCACHE=${CCACHE:-0}

emsdk install latest
emsdk activate latest
if [ "$CCACHE" == "1" ]
then
    emsdk activate ccache-git-emscripten-64bit
fi

make -j`nproc` NATIVE=emscripten BACKTRACE=0 TILES=1 TESTS=0 RUNTESTS=0 RELEASE=1 CCACHE="$CCACHE" LINTJSON=0 cataclysm-tiles.js
