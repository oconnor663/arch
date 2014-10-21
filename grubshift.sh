#! /bin/bash

set -e

if ! grep GRUB_FORCE_HIDDEN_MENU /etc/default/grub > /dev/null ; then
  tmp=$(mktemp)
  cp /etc/default/grub "$tmp"
  cat >> "$tmp" << EOF

# https://wiki.archlinux.org/index.php/GRUB#Hide_GRUB_unless_the_Shift_key_is_held_down
GRUB_FORCE_HIDDEN_MENU="true"
EOF
  cp --no-preserve=mode --backup=number "$tmp" /etc/default/grub
fi

cp "$(dirname $BASH_SOURCE)/31_hold_shift" /etc/grub.d

grub-mkconfig -o /boot/grub/grub.cfg
