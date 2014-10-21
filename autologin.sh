#! /bin/bash

dest=/etc/systemd/system/getty@tty1.service.d

mkdir -p "$dest"

cp "$(dirname "$BASH_SOURCE")"/autologin.conf "$dest"
