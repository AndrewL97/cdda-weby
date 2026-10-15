
#!/bin/bash
set -exo pipefail

CCACHE=${CCACHE:-0}

# Ensure EM_CONFIG points to the workflow-installed config unless overridden
export EM_CONFIG="${EM_CONFIG:-$HOME/emsdk/.emscripten}"
echo "EM_CONFIG=$EM_CONFIG"

# Diagnostic: print which emcc we'll use
echo "Which emcc is on PATH: $(which emcc || echo 'emcc not found')"
emcc --version || true

emsdk install latest
emsdk activate latest
if [ "$CCACHE" == "1" ]
then
    emsdk activate ccache-git-emscripten-64bit
fi

# Diagnostic: print which emcc we'll use
echo "Which emcc is on PATH: $(which emcc || echo 'emcc not found')"
emcc --version || true


make -j`nproc` NATIVE=emscripten BACKTRACE=0 TILES=1 TESTS=0 RUNTESTS=0 RELEASE=1 CCACHE="$CCACHE" LINTJSON=0 cataclysm-tiles.js
