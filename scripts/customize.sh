#!/bin/bash
#
# Customizations after base install

source $1

function is_installed() {
    pacman -Q $1 >/dev/null 2>&1
}

function install_pkgs() {
    sudo pacman -Syu --noconfirm --needed $(echo "$PACKAGES")
}

function setup_network() {
    is_installed networkmanager && {
        echo "Disabling dhcpcd and enabling NetworkManager service"
        systemctl disable dhcpcd
        systemctl enable NetworkManager.service
    }
}

function obtain_keys_for_aur() {

    if [ "$AUR_PKGS" == *"dropbox"* ]; then
        sudo  wget https://linux.dropbox.com/fedora/rpm-public-key.asc
        gpg --import rpm-public-key.asc    
    fi

    # Spotify AUR
    if [ "$AUR_PKGS" == *"spotify"* ]; then
        gpg --recv-key D1742AD60D811D58
    fi
}

function install_aur_pkgs() {
    mkdir -p ~/.aur

    for A in ${AUR_PKGS[@]}; do
        cd ~/.aur
        git clone https://aur.archlinux.org/"$A".git
        cd "$A"
        makepkg -si --noconfirm
    done
}

function customize_grub_theme() {
    is_installed arch-silence-grub-theme-git && {
        sudo sed -i 's:#GRUB_THEME="/path/to/gfxtheme":GRUB_THEME="/boot/grub/themes/arch-silence/theme.txt":' /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg    
    }
}

function setup_desktop_environment() {
    # LXDM
    is_installed lxdm && {
        sudo systemctl enable lxdm.service

        sudo sed -i 's/# numlock=0/numlock=1/' /etc/lxdm/lxdm.conf

        is_installed lxdm-themes && {
            sudo sed -i 's/theme=Industrial/theme=Archlinux/' /etc/lxdm/lxdm.conf
        }

        is_installed openbox && {
            sudo sed -i 's:# session=/usr/bin/startlxde:session=/usr/bin/openbox-session:' /etc/lxdm/lxdm.conf
        }    
    }
}



install_pkgs
setup_network
obtain_keys_for_aur
install_aur_pkgs
customize_grub_theme
setup_desktop_environment
