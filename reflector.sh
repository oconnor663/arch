#! /usr/bin/bash

set -e -u -o pipefail

if [[ "$(whoami)" != "root" ]] ; then
    echo needs sudo
    exit 1
fi

# Note that "US," means both US and worldwide mirros.
reflector --country=US, --protocol=https --threads=4 --fastest=5 --save=/etc/pacman.d/mirrorlist
