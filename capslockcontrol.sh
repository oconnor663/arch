#! /bin/bash

set -e

echo Mapping caps lock to control in the Linux console.
keymap_dir=/usr/share/kbd/keymaps/i386/qwerty
cat $keymap_dir/us.map.gz | \
  gunzip | \
  sed 's/keycode  58 = Caps_Lock/keycode  58 = Control/' | \
  gzip > $keymap_dir/us-capscontrol.map.gz
echo KEYMAP=us-capscontrol > /etc/vconsole.conf
