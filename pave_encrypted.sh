#! /bin/bash

set -e

drive="$1"
if [[ -z "$drive" ]] ; then
  echo Must specify a drive.
  exit 1
fi

read -s -p "Disk password: " password; echo
read -s -p "Confirm password: " confirm; echo
if [ "$password" != "$confirm" ]; then
  echo "Passwords don't match."
  exit 1
fi

swap_size=$(free --mega | grep Mem: | awk '{print $2}')

PARTED() {
  parted --script --align optimal "$drive" -- "$@"
}

echo Writing MBR label.
PARTED mklabel msdos
echo Creating boot partition.
PARTED mkpart primary 0% 200M
echo Creating LUKS partition.
PARTED mkpart primary 200M 100%
echo Making boot partition bootable.
PARTED set 1 boot on
echo Formatting boot partition ext4.
boot_part="${drive}1"
mkfs.ext4 -F "$boot_part"

echo Formatting LUKS partition.
luks_part="${drive}2"
echo -n "$password" | cryptsetup --batch-mode luksFormat "$luks_part"
echo -n "$password" | cryptsetup luksOpen "$luks_part" luks

echo Creating logical volumes.
vgcreate luksvg /dev/mapper/luks
lvcreate --size "${swap_size}M" luksvg -n swaplv
swap_dev="/dev/mapper/luksvg-swaplv"
lvcreate --extents 100%FREE luksvg -n rootlv
root_dev="/dev/mapper/luksvg-rootlv"

echo Formatting main volume with btrfs.
mkfs.btrfs "$root_dev"
echo Formatting swap volume.
mkswap "$swap_dev"

echo Mounting "$root_dev" at /mnt.
mount "$root_dev" /mnt
echo Mounting "$boot_part" at /mnt/boot.
mkdir /mnt/boot
mount "$boot_part" /mnt/boot
echo Activating swap.
swapon "$swap_dev"
