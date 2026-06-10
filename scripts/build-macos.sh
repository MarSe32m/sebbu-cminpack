#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./build-macos.sh
#   ./build-macos.sh /path/to/cminpack
#
# Optional environment variables:
#   CMINPACK_VERSION=v1.3.11
#   MACOSX_DEPLOYMENT_TARGET=12.0
#   BUILD_ROOT=build
#   STAGE_ROOT=stage
#   CLEAN=1

CMINPACK_VERSION="${CMINPACK_VERSION:-v1.3.11}"
MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-11.0}"
BUILD_ROOT="${BUILD_ROOT:-build}"
STAGE_ROOT="${STAGE_ROOT:-stage}"
CLEAN="${CLEAN:-0}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${1:-$SCRIPT_DIR/cminpack}"

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required tool '$1' was not found in PATH" >&2
    exit 1
  fi
}

require_tool cmake
require_tool clang
require_tool ar
require_tool ranlib

if command -v ninja >/dev/null 2>&1; then
  GENERATOR="Ninja"
else
  GENERATOR="Unix Makefiles"
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "cminpack source directory not found at: $SOURCE_DIR"
  echo "Cloning cminpack $CMINPACK_VERSION..."
  git clone https://github.com/devernay/cminpack "$SOURCE_DIR"
fi

if [[ -d "$SOURCE_DIR/.git" ]]; then
  git -C "$SOURCE_DIR" fetch --tags --quiet
  git -C "$SOURCE_DIR" checkout "$CMINPACK_VERSION"
fi

build_one_arch() {
  local arch="$1"
  local triple="$2"

  local build_dir="$SCRIPT_DIR/$BUILD_ROOT/$triple"
  local stage_dir="$SCRIPT_DIR/$STAGE_ROOT/$triple"

  echo
  echo "=== Building cminpack for $triple ==="

  if [[ "$CLEAN" == "1" ]]; then
    rm -rf "$build_dir" "$stage_dir"
  fi

  cmake -S "$SOURCE_DIR" -B "$build_dir" \
    -G "$GENERATOR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$stage_dir" \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_OSX_ARCHITECTURES="$arch" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="$MACOSX_DEPLOYMENT_TARGET" \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMINPACK_PRECISION=d \
    -DUSE_BLAS=OFF

  cmake --build "$build_dir" --config Release
  cmake --install "$build_dir" --config Release

  echo "Installed to: $stage_dir"

  echo "Headers:"
  find "$stage_dir/include" -type f -maxdepth 1 -print || true

  echo "Libraries:"
  find "$stage_dir/lib" -type f \( -name "*.a" -o -name "*.dylib" \) -print || true
}

build_one_arch "arm64"  "arm64-apple-macosx"
build_one_arch "x86_64" "x86_64-apple-macosx"

cp stage/arm64-apple-macosx/lib/libcminpack_s.a ../CMinpack.artifactbundle/lib/arm64-apple-macosx/libcminpack_s.a
cp stage/x86_64-apple-macosx/lib/libcminpack_s.a ../CMinpack.artifactbundle/lib/x86_64-apple-macosx/libcminpack_s.a

rm -fr cminpack
rm -fr stage
rm -fr build

echo
echo "=== Done ==="

