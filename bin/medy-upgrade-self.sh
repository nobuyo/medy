#!/usr/bin/env bash

function medy-upgrade-self {
  mv $medy $lab_dir/medy.orig
  get -O $lab_dir/medy "https://raw.githubusercontent.com/nobuyo/medy/master/medy"
  if [ $? -ne 0 ]; then
    error "medy Could not found, reverting"
    mv $lab_dir/medy.orig $medy
    exit 1
  fi

  chmod +x $medy
  success "Updated medy"
}
