#!/usr/bin/env bash
set -eo pipefail

# Build wrapper for CDDA -> Emscripten. Assumes emsdk has already been installed
# and activated in CI (see workflow step). This script only ensures ccache
# activation (if requested) and runs the make target.
#
# Usage: CCACHE=1 ./scripts/build-emscripten.sh

CCACHE=${CCACHE:-0}

# If emsdk is available, prefer the repo-local emsdk binary; otherwise try PATH.
if command -v emsdk >/dev/null 2>&1; then
  EMSDK_CMD="$(command -v emsdk)"
elif [ -x "$HOME/emsdk/emsdk" ]; then
  EMSDK_CMD="$HOME/emsdk/emsdk"
else
  EMSDK_CMD=""
fi

if [ "$CCACHE" = "1" ]; then
  if [ -n "$EMSDK_CMD" ]; then
    # Activate emsdk-provided ccache helper (no-op if already active)
    "$EMSDK_CMD" activate ccache-git-emscripten-64bit || true
  else
    echo "Warning: emsdk command not found; cannot activate ccache wrapper. Continuing..."
  fi
fi

# Run the build. Let make decide parallelism.
make -j"$(nproc)" NATIVE=emscripten BACKTRACE=0 TILES=1 TESTS=0 RUNTESTS=0 RELEASE=1 CCACHE="$CCACHE" LINTJSON=0 cataclysm-tiles.js
