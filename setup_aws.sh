#! /usr/bin/env bash

set -x -v -e -u -o pipefail

pacman -Syu --noconfirm zsh tmux neovim python-pynvim git htop ncdu fd fzf yay rustup mosh

yay -S --noconfirm peru

pacman -R --noconfirm vim

ln -s nvim /usr/bin/vim

useradd -m jacko
gpasswd -a jacko wheel
chsh -s /bin/zsh jacko
userdel -r arch

echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel_nopasswd

# Bug? The locale.gen file seems to be misconfigured.
echo en_US.UTF-8 UTF-8 > /etc/locale.gen
locale-gen

sudo -u jacko bash << END
cd ~
mkdir .ssh
cat > .ssh/authorized_keys << KEY_END
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDzUgIeGuCHm8SSc0n/QHSOShMVTiYb1WRH5EzWdlybDzks8UzHBptpu6KlJklk6AdAbt5sMa1k/7pYQ9jj8EwYFKDRsUeuZGz5P5bvZnpv+mUEZ/C+xmBjZCTCaHt3oDtEAmfA9GFtfzXx/299RWSIDRLX/zeMfHyjfulVrZq8/UBbZOdX9URt+5fzuuklnNNepNbekLaWNXLIASBnu6fNc6QWULgYrExUWTmFjtqB7/Uqx6cVYOxd+Db6a4Z+D876Tj9JiwoSNnWnBy32uyEJ+Pjt+ZvUmH15GUyIjHo2N/9fJvg8biMJs+Tmd0NH8S14pAK1K2LI8fD9zq9ODs+N jacko@athena2
KEY_END
git clone https://github.com/oconnor663/arch
git clone https://github.com/oconnor663/dotfiles
git clone https://github.com/oconnor663/founder
rustup install stable
cargo install --path founder
./dotfiles/install.sh
END
