#! /bin/bash

set -ev

# We need the proprietary Nvidia drivers to handle our external monitors.
if pacman -Qsq | grep mesa-libgl > /dev/null; then
  # This package conflicts with nvidia-libgl. Force remove it if it's installed.
  pacman -Rdd --noconfirm mesa-libgl
fi
pacman -S --noconfirm --needed nvidia

# The Nvidia driver doesn't allow us to adjust screen brightness by default for
# some reason. We need to configure it.
# Also disable the Nvidia logo splash screen.
sudo cat << END > /usr/share/X11/xorg.conf.d/10-nvidia-brightness.conf
Section "Device"
    Identifier     "Device0"
    Driver         "nvidia"
    VendorName     "NVIDIA Corporation"
    BoardName      "Quadro K1000M"
    Option         "RegistryDwords" "EnableBrightnessControl=1"
    Option         "NoLogo" "1"
EndSection
END
