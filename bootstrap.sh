#! /bin/bash

pacman -Sy --noconfirm git reflector

git config --global user.name "Jack O'Connor"
git config --global user.email "oconnor663@gmail.com"

git clone https://github.com/oconnor663/arch
