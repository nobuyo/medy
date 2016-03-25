#!/usr/bin/env bash

function medy-doctor {
  # check dependencies of installed packages
  local installed="$(awk '{print $1}' /etc/setup/installed.db | tail -n +2 | grep -v '^lib' )"
  local checklist=()
  local pkg
  local ready=1

  echo -n "Checking packages availablity.... "

  for pkg in $installed;
  do
    is-available $pkg || { #medy-info $pkg &>/dev/null || {
        echo "$pkg is not available"
        ready=0
    }
  done

  if [ "$ready" = 1 ]; then
    echo -e "\033[32mOK!\033[m"
  fi

  echo -n "Checking update.... "
  ready=1

  wget -q https://raw.githubusercontent.com/nobuyo/medy/master/medy -O - |\
   ( cat $medy | diff /dev/fd/3 -) 3<&0 &>/dev/null ||
  {
    echo;
    warn ":medy has update, please run \"medy upgrade-self\""
    ready=0
  }

  if [ "$ready" = 1 ]; then
    echo -e "\033[32mOK!\033[m"
  fi
}
