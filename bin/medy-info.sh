#!/usr/bin/env bash

function info-self {
  medy-version

  setlab
  echo -n "  " ;where_mirror $mirror
  echo -n "  " ;where_dir $cache
  exit 0
}

function medy-info {
  if [ $# -eq 0 ]; then
    info-self
  fi

  setlab
  export SETUP_INI_FILE_PATH=$cache/$dir$arch/setup.ini

  local info="$(grep -wA10 "^@ $1$" $cache/$dir$arch/setup.ini |\
  sed -e 's/^@\s//g' |\
  grep -v 'ldesc\|install:\|source:' |\
  sed '/prev/,+2d' |\
  sed -e 's/category: //g' -e 's/sdesc: //g' |\
  sed  -e 's/"//g' -e 's/requires: //g' -e 's/version: //g' -e 's/\\n//g')"

  if [ "$info" == "" ]; then
    error "Unable to find $1"
    return 1
  fi

  local current_version="$(grep "^$1" /etc/setup/installed.db | head -1 | awk '{print $2}')"

  local info_desc="$(setup-parser $1 sdesc)"
  local info_version="$(setup-parser $1 version)"
  local info_require="$(setup-parser $1 requires)"
  local info_category="$(setup-parser $1 category)"


  echo -e "\033[35;4m Infomation \033[m"
  echo "$1"
  echo -e "\033[35;4m Description \033[m"""
  echo "$info_desc"
  echo -e "\033[35;4m Category \033[m"""
  echo "$info_category"
  echo -e "\033[35;4m Requires \033[m"""""
  echo "$info_require"
  echo -e "\033[35;4m Version \033[m"""
  echo "$info_version"

  echo -e "\033[35;4m Status \033[m"""
  grep "^$1" /etc/setup/installed.db &> /dev/null
  if [ $? -eq 0 ]; then
    echo "Installed (${current_version%.*.*})"
  else
    echo "Not installed"
  fi
}
