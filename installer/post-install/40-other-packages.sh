#!/bin/env bash
#
# Installation scripts for non-Arch/non-AUR packages

# Sublime Text
curl -O https://download.sublimetext.com/sublimehq-pub.gpg
sudo pacman-key --add sublimehq-pub.gpg
sudo pacman-key --lsign-key 8A8F901A
rm sublimehq-pub.gpg
echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
sudo pacman -Syu --noconfirm sublime-text

# SDKMAN
curl -s "https://get.sdkman.io" | bash


