
#!/bin/bash
set -exo pipefail

CCACHE=${CCACHE:-0}

emsdk install latest
emsdk activate latest
if [ "$CCACHE" == "1" ]
then
    emsdk activate ccache-git-emscripten-64bit
fi

# Ensure EM_CONFIG points to the workflow-installed config unless overridden
       
export EM_CONFIG="$HOME/emsdk/.emscripten"
echo "EMCONFIG IS $EM_CONFIG"

# Force Emscripten to use SDL3 and related ports from the ports system
EM_PORT_FLAGS="-sUSE_SDL=3 -sUSE_SDL_IMAGE=3 -sUSE_SDL_MIXER=3"
export CFLAGS="$CFLAGS $EM_PORT_FLAGS"
export CXXFLAGS="$CXXFLAGS $EM_PORT_FLAGS"
export LDFLAGS="$LDFLAGS $EM_PORT_FLAGS"

# Silence the unused-function warning
export CXXFLAGS="$CXXFLAGS -Wno-unused-function -Wno-error=unused-function"

# Diagnostic: print which emcc we'll use
echo "Which emcc is on PATH: $(which emcc || echo 'emcc not found')"
emcc --version || true


make -j`nproc` NATIVE=emscripten BACKTRACE=0 TILES=1 TESTS=0 RUNTESTS=0 RELEASE=1 CCACHE="$CCACHE" LINTJSON=0 cataclysm-tiles.js
