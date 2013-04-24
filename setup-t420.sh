#! /bin/bash

set -ev

# Linux won't boot properly on this laptop without the 'nox2apic' kernel
# parameter. Something like this is required for Ubuntu too.
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="nox2apic"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# We need the proprietary Nvidia drivers to handle our external monitors.
if pacman -Qsq | grep mesa-libgl > /dev/null; then
  # This package conflicts with nvidia-libgl. Force remove it if it's installed.
  pacman -Rdd --noconfirm mesa-libgl
fi
pacman -S --noconfirm --needed nvidia
