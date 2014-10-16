#! /bin/bash

set -e

echo Allowing users in wheel to sudo without a password.
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel_nopasswd
