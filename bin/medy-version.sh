#!/usr/bin/env bash


  # ._ _  _  _|
  # | | |(/_(_|\/
  #            /


medylogo="
  ._ _  _  _\033[31m|\033[m
\033[31m  | | |\033[m(/_(_\033[31m|\033[m\033[34m\/\033[m
             /
"
function medy-version {
  echo -e "$medylogo"
  echo "  version 0.0.2-alpha(\"holy\"-nightly build)"
  echo ""
}