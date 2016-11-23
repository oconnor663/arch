#! /usr/bin/env bash

set -e -u -o pipefail

echo 'LANG="en_US.UTF-8"' > /etc/locale.conf
echo 'en_US.UTF-8 UTF-8'  > /etc/locale.gen
locale-gen
