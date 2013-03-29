#! /bin/bash

pave_drive=/dev/sda

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

# clear the partition table and create one big partition
sgdisk -o -g ${pave_drive}
sgdisk -n 0:0:0 ${pave_drive}
main_partition=${pave_drive}1
mkfs -t ext4 $main_partition
mount $main_partition /mnt

# install base packages. syslinux is our bootloader, and it requires
# gptfdisk to work with the GPT partitions we created above
pacstrap /mnt base base-devel syslinux gptfdisk networkmanager

genfstab -p /mnt >> /mnt/etc/fstab

echo arch-host > /mnt/etc/hostname

ln -s /usr/share/zoneinfo/US/Pacific /mnt/etc/localtime

echo 'LANG="en_US.UTF-8"' > /mnt/etc/locale.conf
echo 'en_US.UTF-8 UTF-8'  > /mnt/etc/locale.gen
$CHROOT locale-gen

$CHROOT mkinitcpio -p linux

$CHROOT syslinux-install_update -i -a -m
# syslinux targets sda3 by default, not sure why
sed -i s*root=/dev/sda3*root=$main_partition* /mnt/boot/syslinux/syslinux.cfg

cat > /mnt/etc/sudoers << END
root ALL=(ALL) ALL
%wheel ALL=(ALL) ALL
END

$CHROOT useradd -m -G wheel "$user"
echo "$user:$password" | $CHROOT chpasswd
$CHROOT passwd -l root

curl https://raw.github.com/oconnor663/arch/master/setup.sh > setup.sh
cat setup.sh | $CHROOT bash
