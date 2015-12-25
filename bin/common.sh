#!/usr/bin/env bash

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
  if is-available "wget" && [ $noisy_view = 1 ]; then
    command wget "$@"
  # elif is-available "curl"; then
  #   command curl -O "${@:2}"
  elif is-available "wget" && [ $noisy_view = 0 ]; then
    command wget "$@" &>/dev/null
  else
    warn wget is not installed, using lynx as fallback
    set "${*: -1}"
    lynx -source "$1" > "${1##*/}"
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

  if [ $noisy_view = 1 ]; then
    where_mirror $mirror
    where_dir $cache
  fi

  mkdir -p "$cache/$dir/$arch"
  cd "$cache/$dir/$arch"
  if [ -e setup.ini ]; then
    export SETUP_INI_FILE_PATH=$cache/$dir/$arch/setup.ini
    return 0
  else
    getsetup
    export SETUP_INI_FILE_PATH=$cache/$dir/$arch/setup.ini
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
