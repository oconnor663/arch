#! /bin/bash

set -e

echo Installing package-query...
cd $(mktemp -d)
curl https://aur.archlinux.org/packages/pa/package-query/PKGBUILD > PKGBUILD
makepkg --asroot --syncdeps --install --noconfirm

echo Installing yaourt...
cd $(mktemp -d)
curl https://aur.archlinux.org/packages/ya/yaourt/PKGBUILD > PKGBUILD
makepkg --asroot --syncdeps --install --noconfirm
