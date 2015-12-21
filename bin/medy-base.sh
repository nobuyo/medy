#!/usr/bin/env bash

# apt-cyg: install tool for cygwin similar to debian apt-get

# The MIT License (MIT)
#
# Copyright (c) 2013 Trans-code Design
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

#> cat ./bin/common.sh | perl -ne 'print unless /^#!/'
#> cat ./bin/medy-*.sh | perl -ne 'print unless /^#!/'

OPT_FILES=()
SUBCOMMAND=""
YES_TO_ALL=false
force=""
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

    --help)
      usage
      exit 0
    ;;

    --version)
      version
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
    warning "File $file not found, skipping"
  fi
done

function invoke_subcommand {
  local SUBCOMMAND="${@:1:1}"
  local ARGS=( "${@:2}" )
  local ACTION="medy-${SUBCOMMAND:-help}"
  if type "$ACTION" &>/dev/null; then
    "$ACTION" "${ARGS[@]}"
  else
    error "unknown command: $SUBCOMMAND"
    exit 1
  fi
}

invoke_subcommand "$SUBCOMMAND" "${ARGS[@]}"