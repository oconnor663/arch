#! /usr/bin/bash

set -e -u -o pipefail

curl -s "https://www.archlinux.org/mirrorlist/?country=US&protocol=https&use_mirror_status=on" \
  | sed -e 's/^#Server/Server/' -e '/^#/d' \
  | rankmirrors -n 5 - \
  > /etc/pacman.d/mirrorlist
