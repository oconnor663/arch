#! /bin/bash

set -e

base_dir=$(dirname "$BASH_SOURCE")

drive="$1"
if [[ -z "$drive" ]] ; then
  echo Must specify a drive.
  exit 1
fi

read -s -p "Root password: " password; echo
read -s -p "Confirm password: " confirm; echo
if [ "$password" != "$confirm" ]; then
  echo "Passwords don't match."
  exit 1
fi

"$base_dir"/reflector.sh

pacstrap /mnt base base-devel grub networkmanager btrfs-progs ntp openssh

genfstab -p /mnt > /mnt/etc/fstab

echo arch-host > /mnt/etc/hostname

ln -sf /usr/share/zoneinfo/America/Los_Angeles /mnt/etc/localtime

echo 'LANG="en_US.UTF-8"' > /mnt/etc/locale.conf
echo 'en_US.UTF-8 UTF-8'  > /mnt/etc/locale.gen
arch-chroot /mnt locale-gen

arch-chroot /mnt grub-install --target=i386-pc --recheck "$drive"
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

arch-chroot /mnt systemctl enable NetworkManager ntpd sshd

echo "root:$password" | arch-chroot /mnt chpasswd
