#! /bin/bash

pave_drive=/dev/sda

#pacman_mirror=0.0.0.0:8080

prepend_mirror() {
  if [ -z $pacman_mirror ] ; then
    return
  fi
  mirrorfile=/etc/pacman.d/mirrorlist
  tempfile=`mktemp`
  echo "Server = http://$pacman_mirror" > $tempfile
  cat $mirrorfile >> $tempfile
  cp $tempfile $mirrorfile
}

echo "About to DELETE EVERYTHING from $pave_drive."
echo "If you're not sure, CTRL-C now."
echo

read -p "New username: " user
read -s -p "New password: " password; echo
read -s -p "Confirm password: " confirm; echo
if [ "$password" != "$confirm" ]; then
  echo "Passwords don't match."
  exit 1
fi

CHROOT="arch-chroot /mnt"

set -ev

# install tools that are missing from the basic media
prepend_mirror
pacman -Sy --noconfirm --needed reflector

# update the mirror list
reflector --country 'United States' -f 5 --save /etc/pacman.d/mirrorlist
prepend_mirror

# clear the disk and create the boot and root partitions
# root partition is of the LVM type (8e)
fdisk $pave_drive << END
o
n
p
1

+200M
n
p
2


t
2
8e
w
END

# format both new partitions
boot_part=${pave_drive}1
mkfs.ext4 $boot_part
luks_part=${pave_drive}2

# set up LUKS encryption on the root partition
echo -n "$password" | cryptsetup --batch-mode luksFormat $luks_part
echo -n "$password" | cryptsetup luksOpen $luks_part lvm
vgcreate mainvg /dev/mapper/lvm
lvcreate -l 100%FREE mainvg -n rootlv
mkfs.ext4 /dev/mapper/mainvg-rootlv

# mount root and /boot partitions for installation
mount /dev/mainvg/rootlv /mnt
mkdir -p /mnt/boot
mount $boot_part /mnt/boot

# install base packages. syslinux is our bootloader, and it requires
# gptfdisk to work with the GPT partitions we created above
pacstrap /mnt base base-devel grub networkmanager zsh

genfstab -p /mnt >> /mnt/etc/fstab

# create a swap file of the same size as the total memory
swap_size=$(free --bytes | grep Mem: | awk '{print $2}')
swap_path=/mnt/swapfile
fallocate -l $swap_size $swap_path
chmod 600 $swap_path
mkswap $swap_path
echo "/swapfile none swap defaults 0 0" >> /mnt/etc/fstab
swapfile_offset=$(filefrag -v $swap_path | grep -w 0: | awk '{print $4}' | sed 's/\.\.//')

echo arch-host > /mnt/etc/hostname

ln -s /usr/share/zoneinfo/US/Pacific /mnt/etc/localtime

echo 'LANG="en_US.UTF-8"' > /mnt/etc/locale.conf
echo 'en_US.UTF-8 UTF-8'  > /mnt/etc/locale.gen
$CHROOT locale-gen

# add LUKS hooks for mkinitcpio...
newhooks=$(grep -E '^HOOKS=' /mnt/etc/mkinitcpio.conf | sed 's/filesystems keyboard/keymap keyboard usbinput encrypt resume lvm2 filesystems/')
sed -i "/^HOOKS=/ c $newhooks" /mnt/etc/mkinitcpio.conf
# ...and for grub
sed -i "/^GRUB_CMDLINE_LINUX=/ c GRUB_CMDLINE_LINUX=\"cryptdevice=$luks_part:mainvg resume=/dev/mapper/mainvg-rootlv resume_offset=$swapfile_offset\"" /mnt/etc/default/grub

$CHROOT mkinitcpio -p linux

$CHROOT grub-install --recheck $pave_drive
$CHROOT cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
$CHROOT grub-mkconfig -o /boot/grub/grub.cfg

$CHROOT useradd -m -G wheel -s /usr/bin/zsh "$user"
echo "$user:$password" | $CHROOT chpasswd
$CHROOT passwd -l root

curl https://raw.github.com/oconnor663/arch/master/setup.sh > setup.sh
cat setup.sh | $CHROOT bash
