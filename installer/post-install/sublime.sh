#!/bin/bash
#
# Installation script for Sublime-Text

curl -O https://download.sublimetext.com/sublimehq-pub.gpg

sudo pacman-key --add sublimehq-pub.gpg
sudo pacman-key --lsign-key 8A8F901A
rm sublimehq-pub.gpg

echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
sudo pacman -Sy --noconfirm sublime-text sublime-merge

# See `somewhere else` for License and Dotfiles
mkdir -p ~/.config/sublime-text-3/Local
#cp /storage/dev/secrets/sublime-text/License.sublime_license ~/.config/sublime-text-3/Local/
mkdir -p ~/.config/sublime-text-3/Packages
#ln -s ~/dotfiles/sublime ~/.config/sublime-text-3/Packages/User
