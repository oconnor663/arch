#! /bin/bash

set -v -e -u -o pipefail

packages=(
    base
    base-devel
    linux
    linux-firmware
    intel-ucode
    networkmanager
    reflector
)

drive="${1:-}"
if [[ -z "$drive" ]] ; then
  echo Must specify a drive.
  exit 1
fi

read -s -p "New password: " password; echo
read -s -p "Confirm password: " confirm; echo
if [ "$password" != "$confirm" ]; then
  echo "Passwords don't match."
  exit 1
fi

# Turn on NTP on the host, so that the time is synced when we get to hwclock.
timedatectl set-ntp on

# Note that "US," means both US and worldwide mirros.
reflector --country=US, --protocol=https --threads=4 --fastest=5 --save=/etc/pacman.d/mirrorlist

PARTED() {
  parted --script --align optimal "$drive" -- "$@"
}
PARTED mklabel gpt
PARTED mkpart primary 0% 512MiB
PARTED set 1 esp on
boot_partition="${drive}1"
mkfs.fat -F32 "$boot_partition"
PARTED mkpart primary 512MiB 100%
luks_partition="${drive}2"
luks_name="luks"
echo -n "$password" | cryptsetup --batch-mode luksFormat "$luks_partition"
echo -n "$password" | cryptsetup luksOpen "$luks_partition" "$luks_name"
root_device="/dev/mapper/$luks_name"
mkfs.btrfs "$root_device"

mount "$root_device" /mnt
mkdir /mnt/boot
mount "$boot_partition" /mnt/boot

pacstrap /mnt "${packages[@]}"

genfstab -p /mnt > /mnt/etc/fstab

echo arch-host > /mnt/etc/hostname

ln -sf /usr/share/zoneinfo/America/New_York /mnt/etc/localtime

echo 'LANG="en_US.UTF-8"' > /mnt/etc/locale.conf
echo 'en_US.UTF-8 UTF-8'  > /mnt/etc/locale.gen

mkdir -p /mnt/boot/loader/entries
cat > /mnt/boot/loader/entries/arch.conf <<END
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options cryptdevice=$luks_partition:$luks_name root=$root_device rw
END

cat > /mnt/etc/mkinitcpio.conf <<END
HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)
END

arch-chroot /mnt bash -v -e -u -o pipefail <<END
  locale-gen

  systemctl enable NetworkManager

  hwclock --systohc

  mkinitcpio -p linux
  bootctl --path=/boot install

  echo "root:$password" | chpasswd
END
