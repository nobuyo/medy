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

function get_fullpath {
  echo $(cd $(dirname $0); pwd)
}

lab_dir=$(get_fullpath ${BASH_SOURCE:-$0})
medy="$lab_dir"/$(basename $0)

function warn {
  # color:yellow
  echo -e "\033[33mWarning\033[m" "$*"
}

function error {
  # color:red
  echo -e "\033[31mError\033[m" "$*"
}

function success {
  # color:green
  echo -e "\033[32mSuccess\033[m" "$*"
}

function where_mirror {
  echo "Mirror server is $1"
}

function where_dir {
  echo "Cache directory is $1"
}

function cygwin_arch {
  # arch | awk '{sub("i686", "x86"); print $0;}'
  uname -m | awk '{sub("i686", "x86"); print $0;}'
}

function encode_mirror_url {
  echo "$1" | sed -e "s/:/%3a/g" -e "s:/:%2f:g"
}

function is-available {
  which "$1" &>/dev/null
  return $?
}

function checkpackages {
  if [ $# -eq 0 ]; then
    echo Nothing to do, exiting
    exit 0
  fi
}

function get {
  if is-available "wget"; then
    command wget "$@" &>/dev/null
  # elif is-available "curl"; then
  #   command curl -O "${@:2}"
  else
    warn "wget not installed."
  fi
}

function setlab {
  # get mirror and cache dir from local
  #default
  mirror=ftp://ftp.iij.ad.jp/pub/cygwin
  cache=~/medycache
  arch="$(cygwin_arch)"

  if [ -e /etc/setup/last-mirror ]; then
    mirror="$(head -1 /etc/setup/last-mirror)"
  elif [ -e /etc/setup/setup.rc ]; then
    mirror="$(awk '/last-mirror/ {getline; print $1}' /etc/setup/setup.rc)"
  fi

  dir="$(encode_mirror_url "$mirror/")"

  if [ -e /etc/setup/last-cache ]; then
    cache="$(cygpath -au "$(head -1 /etc/setup/last-mirror)")"
  elif [ -e /etc/setup/setup.rc ]; then
    cache="$(cygpath -au "$(awk '/last-cache/ {getline; print $1}' /etc/setup/setup.rc)")"
  fi

  where_mirror $mirror
  where_dir $cache

  mkdir -p "$cache/$dir/$arch"
  cd "$cache/$dir/$arch"
  if [ -e setup.ini ]; then
    return 0
  else
    getsetup
    return 1
  fi
}

function getsetup {
  touch setup.ini
  mv setup.ini setup.ini-save
  get -N $mirror/$arch/setup.bz2
  if [ -e setup.bz2 ]; then
    bunzip2 setup.bz2
    mv setup setup.ini
    success "Updated setup.ini"
  else
    error "Updateing setup.ini, reverting"
    mv setup.ini-save setup.ini
  fi
}

function ask_user {
  while true
  do
    [ -n "$2" ] && { local pmt="$2"; local def=; }
    [ -n "$2" ] || { local pmt="y/n";local def=; }
    [ $YES_TO_ALL = 1 ] && { local RPY=Y;local def=Y; }
    [ -z "$def" ] && { echo -ne "$1 ";read -p "[$pmt] " RPY; }
    [ -z "$RPY" ] && { local RPY=$def; }
    case "$RPY" in
      Y*|y*) return 0 ;;
      N*|n*) return 1 ;;
         1*) return 0 ;;
         2*) return 1 ;;
    esac
  done
}
#> cat ./bin/medy-*.sh | perl -ne 'print unless /^#!/'

function medy-doctor {
  # check dependencies of installed packages
  echo "\"doctor\" coming soon, exiting"
}

function medy-find {
  medy-search "$@"
}

function medy-help {
  usage
}

function usage {
  echo "medy: Install (or build) and remove Cygwin package"
  echo "  \"medy install <package names>\" to install packages"
  echo "  \"medy resume-install\"          to resume interrupted installing"
  echo "  \"medy (remove|uninstall) <package names>\"  to remove packages"
  echo "  \"medy update\"                  to update setup.ini"
  echo "  \"medy list\"                    to show installed packages"
  echo "  \"medy (search|find) <patterns>\"       to find packages"
  echo "  \"medy info <package name>\"     to show package infomation"
  echo "  \"medy upgrade-self\"            to upgrade medy"
  echo ""
  echo "Options:"
  echo "  --force               : force install/remove/fetch trustedkeys"
  echo "  --mirror, -m <url>    : set mirror server"
  echo "  --help"
  echo "  --version"
}

function medy-info {
  checkpackages "$@"
  setlab

  info="$(grep -wA10 "^@ $1$" $cache/$dir/$arch/setup.ini |\
  sed -e 's/^@\s//g' |\
  grep -v 'ldesc\|install:\|source:' |\
  sed '/prev/,+2d' |\
  sed -e 's/category: //g' -e 's/sdesc: //g' |\
  sed  -e 's/"//g' -e 's/requires: //g' -e 's/version: //g' -e 's/\\n//g')"

  if [ "$info" == "" ]; then
    error "Unable to find $1"
    return
  fi

  info_desc="$(echo "$info" | head -n -3 | tail -n +2)"
  info_version="$(echo "$info" | tail -1)"
  info_require="$(echo "$info" | tail -2 | head -1)"
  info_category="$(echo "$info" | tail -3 | head -1)"

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
  grep "$1" /etc/setup/installed.db &> /dev/null
  if [ $? -eq 0 ]; then
    echo "Installed"
  else
    echo "Not installed"
  fi
}

function medy-install {
  local pkg
  local script

  checkpackages "$@"
  #setlab
  noupdate=1
  getsetup
  echo

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
  get -O "$(cat /tmp/medy-downloads)" ||
  {
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


function medy-list {
    echo 1>&2 The installed packages as follows:
    awk '/[^ ]+ [^ ]+ 0/ {print $1}' /etc/setup/installed.db
}

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
  for req in $dontremove
  do
    local dontremove="cygwin coreutils gawk bzip2 tar xz wget aria2 bash"
    if [ "$1" = "$req" ]; then
      echo; error "medy cannot remove package $p, exiting"
      return 1
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


      verify-remove $p

      # local dontremove="cygwin coreutils gawk bzip2 tar xz wget aria2 bash"
      # for req in $dontremove
      # do
      #   if [ "$p" = "$req" ]; then
      #     echo; error "medy cannot remove package $p, exiting"
      #     exit 1
      #   fi
      # done

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

function medy-search {
  local pkg

  checkpackages "$@"
  #setlab

  for pkg do
    echo ""
    echo "Searching..."
    echo "from installed packages matching $pkg:"
    awk '/[^ ]+ [^ ]+ 0/ {if ($1 ~ query) print $1}' query="$pkg" /etc/setup/installed.db
    echo ""
    echo "from installable packages matching $pkg:"
    awk -v query="$pkg" \
      'BEGIN{RS="\n\n@ "; FS="\n"; ORS="\n"} {if ($1 ~ query) {print $1}}' \
      setup.ini
  done
}

function medy-uninstall {
  medy-remove "$@"
}

function medy-update {
  setlab
  getsetup
}

function medy-upgrade-self {
  mv $medy $lab_dir/medy.orig
  get -Oq "https://raw.githubusercontent.com/nobuyo/medy/master/medy" -P /lab_dir
  if [ $? -ne 0 ]; then
    error "medy Could not found, reverting"
    $lab_dir/medy.orig $medy
  fi

  chmod 775 $medy
  success "Updated medy"
}

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

medylogo="
  ._ _  _  _|
  | | |(/_(_|\/
             /
"

function medy-version {
  echo "$medylogo"
  echo "  medy version 0.01"
}

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