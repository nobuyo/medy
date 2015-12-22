#!/usr/bin/env bash

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
