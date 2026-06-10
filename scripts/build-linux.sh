#!/usr/bin/env bash

CMINPACK_VERSION="${CMINPACK_VERSION:-1.3.11}"


git clone --branch "v${CMINPACK_VERSION}" https://github.com/devernay/cminpack

# Build amd64
docker buildx build \
    --platform linux/amd64 \
    --output type=local,dest=./artifacts/linux-amd64 \
    .

# Build arm64
docker buildx build \
    --platform linux/arm64 \
    --output type=local,dest=./artifacts/linux-arm64 \
    .

rm -fr cminpack

cp artifacts/linux-amd64/x86_64-unknown-linux-gnu/lib/libcminpack_s.a ../CMinpack.artifactbundle/lib/x86_64-unknown-linux-gnu/libcminpack_s.a
cp artifacts/linux-amd64/x86_64-unknown-linux-musl/lib/libcminpack_s.a ../CMinpack.artifactbundle/lib/x86_64-swift-linux-musl/libcminpack_s.a
cp artifacts/linux-arm64/aarch64-unknown-linux-gnu/lib/libcminpack_s.a ../CMinpack.artifactbundle/lib/aarch64-unknown-linux-gnu/libcminpack_s.a
cp artifacts/linux-arm64/aarch64-unknown-linux-musl/lib/libcminpack_s.a ../CMinpack.artifactbundle/lib/aarch64-swift-linux-musl/libcminpack_s.a

rm -fr artifacts