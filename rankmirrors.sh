#! /usr/bin/bash

set -e -u -o pipefail

dest="/etc/pacman.d/mirrorlist"

# Fail fast.
touch "$dest"

tmpfile="$(mktemp)"
chmod 644 "$tmpfile"

curl -sL "https://www.archlinux.org/mirrorlist/?country=US&protocol=https&use_mirror_status=on" \
  | sed -e 's/^#Server/Server/' -e '/^#/d' \
  | rankmirrors -n 5 - \
  > "$tmpfile"

mv "$tmpfile" "$dest"
