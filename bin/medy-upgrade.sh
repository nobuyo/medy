#!/usr/bin/env bash


function verify-remove {
  # TODO
  # avoid duplication in dontremovewithdep

  local dontremove=(cygwin coreutils gawk bzip2 tar xz wget aria2 bash)
  local dontremovewithdep=()
  
  for dep in ${dontremove[@]}; do
    dontremovewithdep+="$(pkg-depends $dep) "
  done

  dontremove="$(echo $dontremovewithdep | sed -e 's/\s/\n/g' | sort -u | uniq )"

  remove_skip=0
  for req in ${dontremove[@]}; do
    if [[ $1 = $req ]] && [ $remove_skip = 0 ]; then
      warn "medy cannot remove package $1, skipping"
      remove_skip=1
    elif [ $remove_skip = 0 ]; then
      remove_skip=0
    fi
  done
}

function remove-to-upgrade {
  for pkg in $@;
  do
    verify-remove $pkg
    if [ $remove_skip = 0 ]; then
      echo Removing: $pkg
      reinstall+="$pkg "

      if [ -e "/etc/preremove/$pkg.sh" ]; then
        "/etc/preremove/$pkg.sh"
      fi

      gzip -cd "/etc/setup/$pkg.lst.gz" | awk '/[^\/]$/ {print "rm -f \"/" $0 "\""}' | sh
      awk > /tmp/awk.$$ -v pkg="$pkg" '{if (pkg != $1) print $0}' /etc/setup/installed.db
      rm -f "/etc/postinstall/$pkg.sh.done" "/etc/preremove/$pkg.sh" "/etc/setup/$pkg.lst.gz"
      mv /etc/setup/installed.db /etc/setup/installed.db-save
      mv /tmp/awk.$$ /etc/setup/installed.db
    fi
  done
  echo Done.
}

function medy-upgrade {

  setlab
  getsetup

  target=()
  reinstall=()
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
    tarcurrent="$(perl -ne 'print if /^@ \Q$ENV{pkgname}\E\n/.../^@ /' $cache/$dir/$arch/setup.ini |\
      sed '$d' | sed '/prev/,$d' | grep 'install: ' |\
      sed -e 's/install: //g' | awk '{print $1}')"
    infocurrent="${tarcurrent##*/}"
    tarcurrent="${infocurrent%.*.*}"

    if [ "$tarcurrent" != "$tarbase" ]; then
      echo -e "$tarbase \033[32m==>\033[m $tarcurrent"
      target+="$pkgname "
    fi
  done

  sed -i '$d' $cache/$dir/$arch/setup.ini

  if [ $DRY_RUN != 1 ]; then
    echo -e;  ask_user "\033[33mDo you wish upgrade?\033[m" || exit 1

    # backup
    echo ${target[@]} > $cache/$dir/$arch/medy-update-target.dat

    # TODO
    # implement resume-upgrade

    echo -e "\033[36;4mStart Removing...\033[m"
    remove-to-upgrade "$(echo ${target[@]})"
    echo -e "\033[36;4mStart Reinstalling...\033[m"
    medy-install "$(echo ${reinstall[@]})"

    # if [ $? = 0 ]; then
    #   rm $cache/$dir/$arch/medy-update-target.dat
    # fi
  fi
}
