#!/usr/bin/env bash

function medy-upgrade {
  # TODO
  # escape '+' for serching update
  # for example "gcc-g++"

  setlab
  getsetup

  target=()
  archive="$(awk 'BEGIN { OFS="," } {print $1, $2}' /etc/setup/installed.db |\
  tail -n +2 )"

  echo "@ " >> $cache/$dir/$arch/setup.ini

  echo -e "\033[36;4mChecking package update...\033[m"
  for acv in $archive;
  do
    export pkgname="$(echo "$acv" | awk -F, '{print $1}')"
    tarfile="$(echo "$acv" | awk -F, '{print $2}')"
    tarbase="${tarfile%.*.*}"
    # tarcurrent="$(grep -wA22 "^@ $pkgname" $cache/$dir/$arch/setup.ini |\
    #   sed -e 's/^@\s//' | sed '/@/,$d'| sed '/prev/,$d' |\
    #   grep 'install: ' | sed -e 's/install: //g' | awk '{print $1}')"
    tarcurrent="$(perl -ne 'print if /^@ $ENV{pkgname}\n/.../^@ /' $cache/$dir/$arch/setup.ini |\
      sed '$d' | sed '/prev/,$d' | grep 'install: ' |\
      sed -e 's/install: //g' | awk '{print $1}')"
    infocurrent="${tarcurrent##*/}"
    tarcurrent="${infocurrent%.*.*}"

    if [ "$tarcurrent" != "$tarbase" ]; then
      echo "$tarbase => $tarcurrent"
      target+="$pkgname "
    fi
  done

  sed -i '$d' $cache/$dir/$arch/setup.ini

  echo -e;  ask_user "\033[33mDo you wish upgrade?\033[m" || exit 1

  # medy-remove "$(echo ${target[@]})"
  # medy-install "$(echo ${target[@]})"
}
