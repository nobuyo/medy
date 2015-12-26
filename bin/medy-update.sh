#!/usr/bin/env bash

function medy-update {
  setlab
  local previous="$(grep "^@" $cache/$dir/$arch/setup.ini-save | tr -d '@')"
  getsetup
  local current="$(grep "^@" $cache/$dir/$arch/setup.ini | tr -d '@')"
  diff "$previous" "$current"
}
