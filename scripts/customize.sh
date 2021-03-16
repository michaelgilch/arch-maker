#!/bin/bash
#
# Customizations after base install

source common.sh
source $1

function install_aur_pkgs() {
    echo "Installing AUR packages"
    echo "-> $AUR_PKGS"
    
    chr su "$PRIMARY_USER" -l -c "mkdir -p /home/$PRIMARY_USER/.aur"

    chr sed -i 's/^%wheel ALL=(ALL) ALL$/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
    for A in ${AUR_PKGS[@]}; do
        COMMAND="cd /home/$PRIMARY_USER/.aur && git clone https://aur.archlinux.org/$A.git && (cd $A && makepkg -si --noconfirm)" # && cd /home/$PRIMARY_USER/.aur" 
        chr bash -c "su $PRIMARY_USER -s /usr/bin/bash -c \"$COMMAND\""
    done
    chr sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL$/%wheel ALL=(ALL) ALL/' /etc/sudoers

}

function setup_desktop_environment() {
    # LXDM
    is_installed lxdm && setup_lxdm
}

function setup_lxdm() {
    chr systemctl enable lxdm.service
}

install_aur_pkgs
setup_desktop_environment
