#! /bin/bash

core_packages=(
  git
  ipython
  mercurial
  networkmanager
  ntp
  openssh
  tmux
  vim
  zsh
)

core_services=(
  NetworkManager
  ntpd
)

gui_packages=(
  audacity
  chromium
  gedit
  gimp
  gnome
  virtualbox-guest-utils
  vlc
  xf86-input-synaptics
  xf86-video-vesa
  xf86-video-ati
  xf86-video-intel
  xf86-video-nv
)

gui_services=(
  gdm.service
)

install_aur() {
  for package in $*; do
    if pacman -Qi $package > /dev/null 2>&1; then
      echo $package is already installed
      continue
    fi

    cd `mktemp -d`
    tarball=$package.tar.gz
    curl -o $tarball https://aur.archlinux.org/packages/${package:0:2}/$package/$tarball
    tar xf $tarball
    cd $package
    makepkg -si --asroot --noconfirm
  done
}

set -ev

pacman -S --noconfirm --needed ${core_packages[@]} ${gui_packages[@]}

systemctl enable ${core_services[@]} ${gui_services[@]}

install_aur packer
