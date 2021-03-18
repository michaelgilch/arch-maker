#!/bin/bash
#
# Customizations after base install

#source common.sh
source $1

function is_installed() {
    pacman -Q $1 >/dev/null 2>&1
}

# function install_aur_pkgs() {
#     echo "Installing AUR packages"
#     echo "-> $AUR_PKGS"
    
#     chr su "$PRIMARY_USER" -l -c "mkdir -p /home/$PRIMARY_USER/.aur"

#     chr sed -i 's/^%wheel ALL=(ALL) ALL$/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
#     for A in ${AUR_PKGS[@]}; do
#         COMMAND="cd /home/$PRIMARY_USER/.aur && git clone https://aur.archlinux.org/$A.git && (cd $A && makepkg -si --noconfirm)" # && cd /home/$PRIMARY_USER/.aur" 
#         chr bash -c "su $PRIMARY_USER -s /usr/bin/bash -c \"$COMMAND\""
#     done
#     chr sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL$/%wheel ALL=(ALL) ALL/' /etc/sudoers

# }

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
    #chr systemctl enable lxdm.service
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



# Temporarily disable sudo password
#sed -i 's/^%wheel ALL=(ALL) ALL$/%wheel ALL=(ALL) NOPASSWD: ALL/' /mnt/etc/sudoers

# Copy Configs
#mkdir -p /mnt/home/"$PRIMARY_USER"/.install_scripts
#cp ./* /mnt/home/"$PRIMARY_USER"/.install_scripts/

setup_aur_pkgs

setup_desktop_environment




# Re-enable sudo password
#sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL$/%wheel ALL=(ALL) ALL/' /mnt/etc/sudoers




touch abc
#install_aur_pkgs
setup_desktop_environment
