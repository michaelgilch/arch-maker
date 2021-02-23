#!/bin/bash
#
# Installs packages from the main Arch Linux Repo
#
# The following have already been installed via the main install scripts pacstrap
#   base base-devel git linux dhcpcd grub os-prober openssh vim

PACKAGES=""

# CLI
PACKAGES+="bash-completion bc readline scrot tree wget "

# GUI
PACKAGES+="xorg-server nvidia nvidia-settings nvidia-utils openbox obconf lxappearance-obconf lxdm nitrogen tint2 arc-icon-theme arc-gtk-theme ttf-hack ttf-dejavu "

# UTILITIES
PACKAGES+="conky terminator pcmanfm gmrun galculator gsimplecal file-roller gparted p7zip gzip unzip unrar "

# IMAGING
PACKAGES+="gpicview "

# AUDIO
PACKAGES+="alsa-utils pulseaudio pulseaudio-alsa pavucontrol volumeicon "

# VIDEO
PACKAGES+="vlc "

# DOCUMENTS
PACKAGES+="libreoffice-fresh evince "

# DEVEL
PACKAGES+="diff-so-fancy intellij-idea-community-edition libisoburn squashfs-tools shellcheck pacman-contrib ruby " 

sudo pacman -Syu $(echo "$PACKAGES") --noconfirm
