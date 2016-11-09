#! /bin/bash

set -e

drive="$1"
if [[ -z "$drive" ]] ; then
  echo Must specify a drive.
  exit 1
fi

grub_flags="cryptdevice=${drive}2:luks root=/dev/luksvg/rootlv resume=/dev/luksvg/swaplv"

grub_tmp=$(mktemp)

cat /mnt/etc/default/grub \
  | sed -E '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/\bquiet\b//' \
  | sed -E '/^GRUB_CMDLINE_LINUX=/ s?=""?="'"$grub_flags"'"?' \
  > "$grub_tmp"

cp --no-preserve=mode --backup=number "$grub_tmp" /mnt/etc/default/grub

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

mkinitcpio_tmp=$(mktemp)

sed '/^HOOKS=/ s/block filesystems/block encrypt lvm2 resume filesystems keyboard/' \
  /etc/mkinitcpio.conf > "$mkinitcpio_tmp"

cp --no-preserve=mode --backup=number "$mkinitcpio_tmp" /mnt/etc/mkinitcpio.conf

arch-chroot /mnt mkinitcpio -p linux
