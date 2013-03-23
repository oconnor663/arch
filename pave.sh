#! /bin/bash

set -ex

chroot="arch-chroot /mnt"

# clear the partition table and create one big partition
sgdisk -o /dev/sda
sgdisk -n 0:0:0 /dev/sda
mkfs -t ext4 /dev/sda1
mount /dev/sda1 /mnt

# install base packages. syslinux is our bootloader, and it requires
# gptfdisk to work with the GPT partitions we created above
pacstrap /mnt base base-devel syslinux gptfdisk

genfstab -p /mnt >> /mnt/etc/fstab

echo arch-host > /mnt/etc/hostname

ln -s /usr/share/zoneinfo/US/Pacific /mnt/etc/localtime

echo 'LANG="en_US.UTF-8"' > /mnt/etc/locale.conf
echo 'en_US.UTF-8 UTF-8'  > /mnt/etc/locale.gen
$chroot locale-gen

$chroot mkinitcpio -p linux

$chroot syslinux-install_update -i -a -m
# syslinux targets sda3 by default, not sure why
sed -i s/sda3/sda1/g /mnt/boot/syslinux/syslinux.cfg

$chroot passwd
