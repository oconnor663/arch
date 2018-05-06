#! /bin/bash

set -e -u -o pipefail

echo Installing yay...
cd $(mktemp -d)
curl https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay > PKGBUILD
makepkg --syncdeps --install --noconfirm
