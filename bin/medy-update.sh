#!/usr/bin/env bash

function medy-update {
  setlab
  grep "^@" $cache/$dir/$arch/setup.ini-save | tr -d '@' > /tmp/medylist-save
  getsetup
  grep "^@" $cache/$dir/$arch/setup.ini | tr -d '@' > /tmp/medylist
  local dif="$(diff -u /tmp/medylist-save /tmp/medylist)"

  if [ ! -z "$dif" ]; then
    # if there were some changes => disp pkg name
    echo -e "\033[33m==>Updated package\033[m"
    echo "$dif" | grep '^\+\s' | sed -e 's/\+ //g'
  else
    echo "setup.ini already latest version"
  fi

  # rm /tmp/medylist /tmp/medylist-save
}
