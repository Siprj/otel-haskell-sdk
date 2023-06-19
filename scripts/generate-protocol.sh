#!/usr/bin/env bash

set -e

if ! type -P protoc >/dev/null 2>&1; then
  printf '%s\n' 'protoc is not available' 1>&2
  exit 1
fi

if ! type -P proto-lens-protoc >/dev/null 2>&1; then
  printf '%s\n' 'proto-lens-protoc is not available' 1>&2
  exit 1
fi

PROTO_LENS=$(type -P proto-lens-protoc)

SOURCE_PATH="$(git rev-parse --show-toplevel)"

cd "${SOURCE_PATH}/protocol/"

OTLP_VERSION=$(awk '{print $1; exit}' OTLP_VERSION)

if ! test -n "$OTLP_VERSION"; then
  printf '%s\n' 'Otel protobuf version not specified in OTLP_VERSION file'
  exit 1
fi

# clone opentelemetry-proto repository
test -e opentelemetry-proto && rm -fr opentelemetry-proto
git clone -q https://github.com/open-telemetry/opentelemetry-proto.git
git -C opentelemetry-proto reset --hard "$OTLP_VERSION" 1>/dev/null

# generate Haskell opentelemetry protocol files
find ./opentelemetry-proto/ -type f -name \*.proto -print0 |
  xargs -r0 -L1 protoc --plugin=protoc-gen-haskell="$PROTO_LENS" \
    --haskell_out=./src/ --proto_path=./opentelemetry-proto/

# patch generated files for ignoring linting
find ./src/ -type f -name \*.hs -print0 |
  xargs -r0 -L1 grep -FLZ '{- HLINT ignore -}' |
  xargs -r0 sed -i '1i{- HLINT ignore -}'
