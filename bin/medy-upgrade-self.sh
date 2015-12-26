#!/usr/bin/env bash

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
