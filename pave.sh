#! /bin/bash

set -ex

disk=/dev/sda

# clear the partition table and create one big partition
sgdisk -o $disk
sgdisk -n 0:0:0 $disk
mkfs -t ext4 ${disk}1
mount ${disk}1 /mnt

pacstrap /mnt base base-devel

arch-chroot /mnt pacman -S --noconfirm syslinux

genfstab -p /mnt >> /mnt/etc/fstab
