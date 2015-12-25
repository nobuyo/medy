#!/usr/bin/env bash

function medy-doctor {
  # check dependencies of installed packages
  local installed="$(awk '{print $1}' /etc/setup/installed.db | tail -n +2 )"
  local checklist=()
  local pkg
  local ready=1


  for pkg in $installed;
  do
  	is-available $pkg || echo "$pkg is not available"; ready=0
  done

  if [ "$ready" = 1 ]; then
    echo "doctor: Your system is healty, ready to medy"
  fi
}
