#!/bin/sh -e

fourmolu -i  $(git ls-files '*.hs')
cabal-fmt -i $(git ls-files '*.cabal')
