#! /bin/bash

set -e

drive="$1"
if [[ -z "$drive" ]] ; then
  echo Must specify a drive.
  exit 1
fi

swap_size=$(free --mega | grep Mem: | awk '{print $2}')

PARTED() {
  parted --script --align optimal "$drive" -- "$@"
}

echo Writing MBR label.
PARTED mklabel msdos
echo Creating main partition.
PARTED mkpart primary btrfs 0% "-${swap_size}M"
echo Making main partition bootable.
PARTED set 1 boot on
echo Creating swap partition "(${swap_size}M)".
PARTED mkpart primary linux-swap "-${swap_size}M" 100%

echo Formatting main partition with btrfs.
mkfs.btrfs -f "${drive}1"
echo Formatting swap.
mkswap "${drive}2"
