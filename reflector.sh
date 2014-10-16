#! /bin/bash

set -e

tmp=$(mktemp)

echo -n 'Downloading mirror list... '
reflector --country 'United States' --sort rate -n 5 --save "$tmp"
echo done.

cp --no-preserve=mode --backup=number "$tmp" /etc/pacman.d/mirrorlist
