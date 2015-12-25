#!/usr/bin/env bash

function medy-install {
  local pkg
  local script

  checkpackages "$@"
  setlab
  echo

  mkdir -p /usr/local/Pharmacy

  for pkg do
    local already="$(grep -c "^$pkg " /etc/setup/installed.db)"
    if [ $already -ge 1 ] && [ -z $force ]; then
      warning "Package $pkg is already installed, skipping"
      continue
    fi
    CURRENT="${CURRENT[@]} $pkg"
  done

  if [ -f /tmp/medy-packages ]; then
    warn "Interrupted resolving deps detected, ignoring."
    rm /tmp/medy-*
  fi

  echo -n "Resolving dependencies..."

  resolve_deps

  RESUME_INSTALL=0
  medy-resume-install
}

function resolve_deps {
  while true
  do
    echo -n "."
    pkgs=${CURRENT[@]}
    CURRENT=""
    hasdeps=0

    for pkg in $pkgs
    do
      if [ -f /tmp/medy-packages ]; then
        local installing="$( grep -c "$pkg" /tmp/medy-packages)"
        [ $installing = 0 ] || continue
      fi

      # look for package and save desc file

      mkdir -p "release/$pkg"
      awk > "release/$pkg/desc" -v package=`echo $pkg` \
        'BEGIN{RS="\n\n@ "; FS="\n"} {if ($1 == package) {desc = $0; px++}} \
        END {if (px == 1 && desc != "") print desc; else print "Package not found"}' \
        setup.ini
      local desc="$(< "release/$pkg/desc")"
      if [ "$desc" = "Package not found" ]; then
        echo; error "Package $pkg not found or ambiguous name, exiting"
        rm -r "release/$pkg"
        rm /tmp/medy-* 2> /dev/null
        exit 1
      fi

      # queue current package

      local install="$(awk '/^install: / { print $2; exit }' "release/$pkg/desc")"
      echo "$mirror/$install" >> /tmp/medy-downloads
      echo "  dir=release/$pkg" >> /tmp/medy-downloads
      echo $pkg >> /tmp/medy-packages
      hasdeps=1

      # resolve dependencies

      local requires="$(grep "^requires: " "release/$pkg/desc" |\
        sed -re 's/^requires: *(.*[^ ]) */\1/g' -e 's/ +/ /g')"

      local warn=0

      if [ -n "$requires" ]; then
        for package in $requires
        do
          local already="$(grep -c "$package " /etc/setup/installed.db)"
          if [ $already = 0 ]; then
            CURRENT=( ${CURRENT[@]} $package )
          fi
        done
      fi

      if [ -z "$install" ]; then
        error "Could not find \"install\" in package description: obsolete package?"
        rm /tmp/medy-*
        exit 1
      fi
    done

    # tailcall

    [ $hasdeps = 0 ] && break
  done
}

function medy-resume-install {
  echo; echo
  if [ ! -f "/tmp/medy-packages" ]; then
    echo "Nothing to install, exiting"
    exit 0
  fi

  echo "Following packages will be installed:"
  for p in $( cat /tmp/medy-packages )
  do
    echo -n $p " "
  done
  echo; ask_user "Do you wish to continue?" || quit

  [ $RESUME_INSTALL = 0 ] || setlab

  # download all

  echo "Start downloading..."
  ${ARIA2C[@]} --input-file /tmp/medy-downloads \
                 `[ "$(cygwin_arch)" = "x86" ] || echo "--deferred-input"` ||  {
    echo -e "\e[1;34mInterrupted:\e[0m To resume installing, run \"medy resume-install\" ."
    exit 1
  }

  # unpack all

  for pkg in $( cat /tmp/medy-packages )
  do

    install="$(awk '/^install: / { print $2; exit }' "release/$pkg/desc")"
    file="$(basename "$install")"
    cd "release/$pkg"

    # check the sha512

    while true
    do
      local digest="$(awk '/^install: / { print $4; exit }' "desc")"
      local digactual="$(sha512sum $file | awk '{print $1}')"
      if [ "$digest" != "$digactual" ]; then
        error "SHA512 sum did not match, retry downloading..."
        aria2c $mirror/$install
      else
        break
      fi
    done

    echo "Unpacking: $pkg"
    tar > "/etc/setup/$pkg.lst" xvf "$file" -C /
    gzip -f "/etc/setup/$pkg.lst"
    cd ../..

    # update the package database

    awk > /tmp/awk.$$ -v pkg="$pkg" -v bz=$file \
      '{if (ins != 1 && pkg < $1) {print pkg " " bz " 0"; ins=1}; print $0} \
      END{if (ins != 1) print pkg " " bz " 0"}' \
      /etc/setup/installed.db
    mv /etc/setup/installed.db /etc/setup/installed.db-save
    mv /tmp/awk.$$ /etc/setup/installed.db
  done

  # run all postinstall scripts

  local pis="$(ls /etc/postinstall/*.sh 2>/dev/null | wc -l)"
  if [ $pis -gt 0 ]; then
    echo Running postinstall scripts...
    for script in /etc/postinstall/*.sh
    do
      $script
      mv $script $script.done
    done
  fi
  quit
}

function quit {
  echo "Removing tmp files..."
  rm /tmp/medy-*
  echo Done.
  exit
}

