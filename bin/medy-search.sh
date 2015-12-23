#!/usr/bin/env bash

function medy-search {
  local pkg

  checkpackages "$@"
  setlab
  
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
