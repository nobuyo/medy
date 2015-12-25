#!/usr/bin/env bash

function medy-doctor {
  # check dependencies of installed packages
  # local installed="$(awk '{print $1}' /etc/setup/installed.db | tail -n +2 )"
  # local checklist=()
  # local pkg

  # for pkg in $installed;
  # do
  # 	checklist+="$(pkg-depends $pkg) "
  # done

  # for pkg in $checklist;
  # do
  # 	is-available $pkg || {
  #     echo "$pkg is not available"
  #     echo "Please try medy install $pkg"
  # 	}
  # done

  echo "doctor"
}
