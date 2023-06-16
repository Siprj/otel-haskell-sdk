#!/usr/bin/env sh
set -e
# speed-up fourmolu formatting ignoring auto-generated files
git ls-files '*.hs' ':!:protocol/**' | xargs -r fourmolu -i -q
git ls-files '*.cabal' | xargs -r cabal-fmt -i
