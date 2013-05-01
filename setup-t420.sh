#! /bin/bash

set -ev

# We need the proprietary Nvidia drivers to handle our external monitors.
if pacman -Qsq | grep mesa-libgl > /dev/null; then
  # This package conflicts with nvidia-libgl. Force remove it if it's installed.
  pacman -Rdd --noconfirm mesa-libgl
fi
pacman -S --noconfirm --needed nvidia
