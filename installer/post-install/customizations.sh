#!/bin/bash
#
# Post-Install application customizations
#
# Shellcheck should not follow sourced files.
# They will be linted individually.
# shellcheck disable=SC1090,SC1091

source ~/.install_scripts/common.sh
source ~/.install_scripts/"$1"

function private_configs() {
    log_subheader "Copying Private Configs"
    for entry in "${PRIVATE_CONFIGS[@]}"; do
        IFS='|' read -ra item <<< "$entry"
        local src_loc="private/${item[0]}"
        local dest_loc="$HOME"/"${item[1]}"
        log_info "Copying $src_loc to $dest_loc"
        cp -Rp "$src_loc" "$dest_loc"
    done
    IFS=' '
}

function dotfiles() {
    log_subheader "Dotfiles"
    cd ~ || exit
    log_info "Cloning dotfiles repo from $DOTFILES_REPO"
    git clone "$DOTFILES_REPO"
    cd dotfiles || exit
    log_info "Running dotfiles setup.sh"
    bash ./setup.sh
    cd ~ || exit
}

function home_symlinks() {
    log_subheader "Setting up Home Symlinks"

    # TODO: these are DaVinci specific
    #if ! grep -qs '/storage' /proc/mounts; then
    #    echo "/storage" is not mounted. Aborting.
    #    exit 1
    #fi
    #ln -s /storage/dev ~/dev
    #ln -s /storage/documents ~/documents
    #ln -s /storage/music ~/music
    #ln -s /storage/videos ~/videos
}

function network() {
    log_subheader "Network Setup"
    is_installed networkmanager && {
        log_info "Disabling dhcpcd and enabling NetworkManager service"
        sudo systemctl disable dhcpcd
        sudo systemctl enable NetworkManager.service
    }
}

function grub() {
    log_subheader "Customizing GRUB"
    is_installed arch-silence-grub-theme-git && {
        log_info "Setting up arch-silence theme"
        sudo sed -i 's:#GRUB_THEME="/path/to/gfxtheme":GRUB_THEME="/boot/grub/themes/arch-silence/theme.txt":' /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg    
    }    
}

function desktop() {
    log_subheader "Configuring Desktop"
    # LXDM
    is_installed lxdm && {
        log_info "Enabling lxdm service"
        sudo systemctl enable lxdm.service

        log_info "Turning on numlock"
        sudo sed -i 's/# numlock=0/numlock=1/' /etc/lxdm/lxdm.conf

        is_installed lxdm-themes && {
            log_info "Setting up ArchLinux LXDM theme"
            sudo sed -i 's/theme=Industrial/theme=Archlinux/' /etc/lxdm/lxdm.conf
        }

        is_installed openbox && {
            log_info "Setting openbox to default session"
            sudo sed -i 's:# session=/usr/bin/startlxde:session=/usr/bin/openbox-session:' /etc/lxdm/lxdm.conf
        }    
    }    
}

function main() {
    log_header "Application Customizations"

    "$USE_PRIVATE_CONFIGS" && private_configs
    
    [ "$DOTFILES_REPO" != "" ] && dotfiles

    home_symlinks

    network
    grub
    desktop
}

main