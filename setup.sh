#! /bin/bash

set -ev

core_packages=(
  git
  ipython
  mercurial
  openssh
  networkmanager
  tmux
  vim
  zsh
)

core_services=(
  NetworkManager.service
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

pacman -S --noconfirm --needed ${core_packages[@]} ${gui_packages[@]}

systemctl enable ${core_services[@]} ${gui_services[@]}
