
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

# Silence specific unused warnings that are treated as errors under Emscripten/clang
export CXXFLAGS="$CXXFLAGS -Wno-unused-function -Wno-error=unused-function -Wno-unused-but-set-global -Wno-error=unused-but-set-global"

# Diagnostic: print which emcc/em++ we'll use
echo "Which emcc is on PATH: $(which emcc || echo 'emcc not found')"
echo "Which em++ is on PATH: $(which em++ || echo 'em++ not found')"
emcc --version || true
em++ --version || true

# ENSURE linking uses em++ so the C++ runtime is linked in.
# Set environment vars and also add the DEFAULT_TO_CXX flag as a fallback.
export CC=${CC:-emcc}
export CXX=${CXX:-em++}
export LDFLAGS="$LDFLAGS -sDEFAULT_TO_CXX"

# Build (explicitly pass CC/CXX to make as well)
make -j`nproc` NATIVE=emscripten BACKTRACE=0 TILES=1 TESTS=0 RUNTESTS=0 RELEASE=1 CCACHE="$CCACHE" CC="$CC" CXX="$CXX" LINTJSON=0 cataclysm-tiles.js
