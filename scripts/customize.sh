#!/bin/bash
#
# Customizations after base install

source $1

function install_pkgs() {
    sudo pacman -Syu --noconfirm --needed $(echo "$PACKAGES")
}

function is_installed() {
    pacman -Q $1 >/dev/null 2>&1
}

function setup_desktop_environment() {
    # LXDM
    is_installed lxdm && setup_lxdm
}

function setup_lxdm() {
    sudo systemctl enable lxdm.service

    sudo sed -i 's/# numlock=0/numlock=1/' /etc/lxdm/lxdm.conf

    is_installed lxdm-themes && {
        sudo sed -i 's/theme=Industrial/theme=Archlinux/' /etc/lxdm/lxdm.conf
    }

    is_installed openbox && {
        sudo sed -i 's:# session=/usr/bin/startlxde:session=/usr/bin/openbox-session:' /etc/lxdm/lxdm.conf
    }
}

function setup_network() {
    is_installed networkmanager && {
        echo "Disabling dhcpcd and enabling NetworkManager service"
        servicectl disable dhcpcd
        servicectl enable NetworkManager.service
    }
}

function setup_aur_pkgs() {
    mkdir -p ~/.aur

    for A in ${AUR_PKGS[@]}; do
        cd ~/.aur
        git clone https://aur.archlinux.org/"$A".git
        cd "$A"
        makepkg -si --noconfirm
    done
}


install_pkgs
setup_network
setup_aur_pkgs
setup_desktop_environment
