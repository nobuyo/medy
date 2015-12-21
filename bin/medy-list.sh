#!/bin/bash

function medy-list {
    echo 1>&2 The installed packages as follows:
    awk '/[^ ]+ [^ ]+ 0/ {print $1}' /etc/setup/installed.db
}
