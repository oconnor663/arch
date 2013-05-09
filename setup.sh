#! /bin/bash

core_packages=(
  git
  gnupg
  htop
  ipython
  mercurial
  networkmanager
  ntp
  openssh
  pkgtools
  tmux
  vim
  wget
  zip
  zsh
)

core_services=(
  NetworkManager.service
  ntpd.service
  sshd.service
)

gui_packages=(
  audacity
  chromium
  gedit
  gimp
  gnome
  gnome-tweak-tool
  ttf-ubuntu-font-family
  virtualbox-guest-utils
  vlc
  xf86-input-synaptics
  xf86-video-vesa
  xf86-video-ati
  xf86-video-intel
  xf86-video-nouveau
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
    # --noconfirm is unsuitable, because it answers No to removing
    # conflicting packages. Pipe in `yes` instead :(
    yes | makepkg -si --asroot
  done
}

set -ex

# Caps Lock to Control in console mode
keymap_dir=/usr/share/kbd/keymaps/i386/qwerty
cat $keymap_dir/us.map.gz | gunzip | sed 's/keycode  58 = Caps_Lock/keycode  58 = Control/' | gzip > $keymap_dir/us-capscontrol.map.gz
echo KEYMAP=us-capscontrol > /etc/vconsole.conf

pacman -S --noconfirm --needed ${core_packages[@]} ${gui_packages[@]}

systemctl enable ${core_services[@]} ${gui_services[@]}

install_aur package-query yaourt

# pretty fonts
install_aur freetype2-ubuntu fontconfig-ubuntu cairo-ubuntu otf-ipafont
