#!/usr/bin/env bash

function medy-update {
  setlab
  grep "^@" $cache/$dir/$arch/setup.ini-save > /tmp/medylist-save
  getsetup
  grep "^@" $cache/$dir/$arch/setup.ini | tr -d '@' > /tmp/medylist
  local dif="$(diff -u /tmp/medylist-save /tmp/medylist)"

  if [ ! -z "$dif" ]; then
    echo -e "\033[33m==>New package\033[m"
    echo "$dif" | grep '^\+\s' | sed -e 's/\+ //g'

    echo -e "\033[33m==>Deleted package\033[m"
    echo "$dif"| grep '^-\s' | sed -e 's/- //g'
  else
    echo "setup.ini already latest version"
  fi

  # rm /tmp/medylist /tmp/medylist-save
}
