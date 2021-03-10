#!/bin/bash
# 
# Install AUR packages and other packages from non-Arch sources

pushd ~/dev/aur_pkgs || exit

#
# Google Chrome
#
if [ ! -d google-chrome ]; then
    git clone https://aur.archlinux.org/google-chrome.git
    pushd google-chrome || exit
else
    pushd google-chrome || exit
    git pull
fi
makepkg -si --noconfirm
popd || exit

#
# LXDM Themes
#
if [ ! -d lxdm-themes ]; then
    git clone https://aur.archlinux.org/lxdm-themes.git
    pushd lxdm-themes || exit
else
    pushd lxdm-themes || exit
    git pull
fi
makepkg -si --noconfirm
sudo sed -i 's/theme=Industrial/theme=Archlinux/g' /etc/lxdm/lxdm.conf
sudo sed -i 's:# session=/usr/bin/startlxde:session=/usr/bin/openbox-session:' /etc/lxdm/lxdm.conf
sudo sed -i 's/# numlock=0/numlock=1/' /etc/lxdm/lxdm.conf
popd || exit

#
# Arch-Silence Grub Theme
#
if [ ! -d arch-silence ]; then
    git clone https://aur.archlinux.org/arch-silence-grub-theme-git.git
    pushd arch-silence-grub-theme-git || exit
else
    pushd arch-silence-grub-theme-git || exit
    git pull
fi
makepkg -si --noconfirm
sudo sed -i 's:#GRUB_THEME="/path/to/gfxtheme":GRUB_THEME="/boot/grub/themes/arch-silence/theme.txt":' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
popd || exit

#
# Dropbox
#
if [ ! -d dropbox ]; then
    git clone https://aur.archlinux.org/dropbox.git
    pushd dropbox || exit
else
    pushd dropbox || exit
    git pull
fi
wget https://linux.dropbox.com/fedora/rpm-public-key.asc
gpg --import rpm-public-key.asc
makepkg -si --noconfirm
popd || exit

# 
# ReMarkable Client
#
if [ ! -d remarkable-client ]; then
    git clone https://aur.archlinux.org/remarkable-client.git
    pushd remarkable-client || exit
else
    pushd remarkable-client || exit
    git pull
fi
makepkg -si --noconfirm
popd || exit


#
# Spotify
#
if [ ! -d spotify ]; then
    git clone https://aur.archlinux.org/spotify.git
    pushd spotify || exit
else
    pushd spotify || exit
    git pull
fi
gpg --recv-key D1742AD60D811D58
makepkg -si --noconfirm
popd || exit

#
# Slack
# 
if [ ! -d slack-desktop ]; then
    git clone https://aur.archlinux.org/slack-desktop.git
    pushd slack-desktop || exit
else
    pushd slack-desktop || exit
    git pull
fi
makepkg -si --noconfirm
popd || exit

# 
# H2 Database
#
if [ ! -d h2 ]; then
    git clone https://aur.archlinux.org/h2.git
    pushd h2 || exit
else
    pushd h2 || exit
    git pull
fi
makepkg -si --noconfirm
popd || exit

# INSERT NEW HERE

popd || exit
