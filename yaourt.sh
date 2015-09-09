#! /bin/bash

set -e

echo Installing package-query...
cd $(mktemp -d)
curl https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=package-query > PKGBUILD
makepkg --syncdeps --install --noconfirm

echo Installing yaourt...
cd $(mktemp -d)
curl https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yaourt > PKGBUILD
makepkg --syncdeps --install --noconfirm
