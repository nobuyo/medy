#!/usr/bin/env bash

function medy-remove {
  local pkg
  local req
  valid=0

  setlab
  checkpackages "$@"

  echo

  CURRENT=""
  for pkg in $@
  do
    if [ ! -e "/etc/setup/$pkg.lst.gz" -a -z "$force" ]; then
      echo Package manifest missing, cannot remove $pkg.
      continue
    fi
    valid=1
    CURRENT=( ${CURRENT[@]} $pkg )
  done

  [ $valid = 1 ] || exit -1
  remove-dep
}

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

function remove-dep {
  local pkg
  REMOVE=""
  do_remove=0

  echo -n Resolving dependencies...

  until [ -z $CURRENT ]
  do
    echo -n .
    pkgs=${CURRENT[@]}
    CURRENT=""

    for p in $pkgs
    do
      already="$(grep -c "^$p " /etc/setup/installed.db)"
      removing=`echo ${REMOVE[@]} | grep -c $p`
      ([ $already -gt 0 ] && [ $removing = 0 ]) || continue

      local dontremove="cygwin coreutils gawk bzip2 tar xz wget aria2 bash"
      for req in $dontremove
      do
        if [ "$p" = "$req" ]; then
          echo; error "medy cannot remove package $p, exiting"
          exit 1
        fi
      done

      REMOVE=( ${REMOVE[@]} $p )
      do_remove=1

      neededby=`awk '
        /^@ / {
          pn = $2
        }
        $0 ~ "^requires: .*"query {
          print pn
        }
        ' query="$p" setup.ini`

      for npkg in $neededby
      do
        CURRENT=( ${CURRENT[@]} $npkg )
      done
    done
  done

  echo; echo

  [ $do_remove = 1 ] || { echo Nothing to remove, exiting; exit; }

  echo Following packages will be removed:
  echo ${REMOVE[@]}
  ask_user "Do you wish to continue?" || exit

  for pkg in ${REMOVE[@]};
  do
    echo Removing: $pkg

    if [ -e "/etc/preremove/$pkg.sh" ]; then
      "/etc/preremove/$pkg.sh"
    fi

    gzip -cd "/etc/setup/$pkg.lst.gz" | awk '/[^\/]$/ {print "rm -f \"/" $0 "\""}' | sh
    awk > /tmp/awk.$$ -v pkg="$pkg" '{if (pkg != $1) print $0}' /etc/setup/installed.db
    rm -f "/etc/postinstall/$pkg.sh.done" "/etc/preremove/$pkg.sh" "/etc/setup/$pkg.lst.gz"
    mv /etc/setup/installed.db /etc/setup/installed.db-save
    mv /tmp/awk.$$ /etc/setup/installed.db
  done
  echo Done.
  exit
}
