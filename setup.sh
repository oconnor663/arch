#! /bin/bash

core_packages=(
  ack
  git
  gnupg
  htop
  ipython
  mercurial
  mlocate
  networkmanager
  ntp
  openssh
  pkgtools
  tmux
  wget
  zip
  zsh
)

core_services=(
  NetworkManager.service
  ntpd.service
  sshd.service
)

graphics_drivers=(
  xf86-video-vesa
  xf86-video-ati
  xf86-video-intel
  xf86-video-nouveau
)

gui_packages=(
  audacity
  chromium
  flashplugin
  gedit
  gimp
  gnome
  gnome-tweak-tool
  gvim
  seahorse
  ttf-ubuntu-font-family
  virtualbox-guest-utils
  vlc
  xf86-input-synaptics
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

    cd `mktemp -d --tmpdir=/var/tmp aur_${package}_XXXXXX`
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

# sudoers rules
cat > /etc/sudoers << END
root ALL=(ALL) ALL
%wheel ALL=(ALL) NOPASSWD: ALL
%sudo ALL=(ALL) NOPASSWD: ALL
END

# kill the beep
cat > /etc/modprobe.d/nobeep.conf << END
blacklist pcspkr
END

if ! pacman -Q nvidia-libgl > /dev/null 2>&1 ; then
  # Open source drivers conflict with proprietary Nvidia stuff. Don't try to
  # install them if Nvidia is present
  pacman -S --noconfirm --needed ${graphics_drivers[@]}
fi

pacman -S --noconfirm --needed ${core_packages[@]} ${gui_packages[@]}

systemctl enable ${core_services[@]} ${gui_services[@]}

install_aur package-query yaourt

# pretty fonts
install_aur freetype2-ubuntu fontconfig-ubuntu cairo-ubuntu otf-ipafont
