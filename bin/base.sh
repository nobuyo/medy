#!/usr/bin/env bash

# medy: package manager for Cygwin

# The MIT License (MIT)
#
# Copyright (c) 2015-2016 nobuyo
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

# # for debug
# exec 2> tmp.log
# set -vx

# # using GNU sed (for dev)
# function sed {
#   case `uname` in
#     Darwin) # mac os
#       /usr/local/bin/gsed "$@" ;;
#     *)
#       /usr/bin/sed "$@" ;;
#   esac
# }

#> echo export DEPLOY='true'
#> cat ./bin/common.sh | perl -ne 'print unless /^#!/'
#> cat ./bin/medy-*.sh | perl -ne 'print unless /^#!/'
#> cat ./bin/perl-module/*.sh | perl -ne 'print unless /^#!/'

function include {
  if [ "$DEPLOY" = 'true' ]; then return; fi
  for file in $@; do
    test -f "$file" && source "$file"
  done
}

include ./bin/common.sh
include ./bin/perl-module/*.sh
include ./bin/medy-*.sh

OPT_FILES=()
SUBCOMMAND=""
YES_TO_ALL=false
LOCAL=0
force=""
DRY_RUN=false
noisy_view=0
INITIAL_ARGS=( "$@" )
ARGS=()
while [ $# -gt 0 ]
do
  case "$1" in

    --force)
      force=1
      shift
    ;;

    --mirror|-m)
      echo "${2%/}/" > /etc/setup/last-mirror
      shift ; shift
    ;;

    --yes-to-all|-y)
      YES_TO_ALL=1
      shift
    ;;

    --local)
      LOCAL=1
      shift
    ;;

    --dry-run|-n)
      DRY_RUN=1
      shift
    ;;

    --view|-v)
      noisy_view=1
      shift
    ;;

    --help)
      medy-help
      exit 0
    ;;

    --version|-V)
      medy-version
      exit 0
    ;;

    *)
      if [ -z "$SUBCOMMAND" ]; then
        SUBCOMMAND="$1"
      else
        ARGS+=( "$1" )
      fi
      shift
    ;;
  esac
done

for file in "${OPT_FILES[@]}"
do
  if [ -f "$file" ]; then
    readarray -t -O ${#ARGS[@]} ARGS < "$file"
  else
    warn "File $file not found, skipping"
  fi
done

if [ `cygwin_arch` = "x86" ]; then
  warn "x86 env detected: aria2 can't use --conditional-get, always download and overwrite"
  ARIA2C=( "aria2c" "--allow-overwrite=true" )
else
  ARIA2C=( "aria2c" "--conditional-get" "--allow-overwrite" )
fi

function suggest_subcommand {
  local CORRECT=""
  case "$1" in
    intsall|instll|insatall|instoll)
      CORRECT="install"
      ;;

    remobe|rimove|remov|rmove)
      CORRECT="remove"
      ;;

    updare|updade|uodate)
      CORRECT="update"
      ;;

    uograde)
      CORRECT="upgrade"
      ;;

    kist|lisr|last)
      CORRECT="list"
      ;;

    serach|seatch|fnid|finf)
      CORRECT="search"
      ;;
    
    indo|imfo)
      CORRECT="info"
      ;;

    update-self|uograde-self|upgradeself|upgrade-sekf)
      CORRECT="upgrade-self"
      ;;

    varsion|vertion)
      CORRECT="version"
      ;;

    *)
      exit 1
      ;;

  esac
  echo; echo "Did you mean this?"
  echo -ne "\033[36m==> \033[m"
  ask_user "medy $CORRECT ${ARGS[@]}" || exit 1
  invoke_subcommand "$CORRECT" "${ARGS[@]}"

}

function invoke_subcommand {
  local SUBCOMMAND="${@:1:1}"
  local ARGS=( "${@:2}" )
  local ACTION="medy-${SUBCOMMAND:-help}"
  if type "$ACTION" &>/dev/null; then
    "$ACTION" "${ARGS[@]}"
  else
    error "unknown command: $SUBCOMMAND"
    suggest_subcommand $SUBCOMMAND
  fi
}

invoke_subcommand "$SUBCOMMAND" "${ARGS[@]}"
