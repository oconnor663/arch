#! /bin/bash

set -e

echo Disabling the console beep.
echo blacklist pcspkr > /etc/modprobe.d/nobeep.conf
if lsmod | awk '{print $1}' | grep -w pcspkr > /dev/null ; then
  rmmod pcspkr
fi
