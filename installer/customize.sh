#!/bin/bash
#
# Customizations after base install
#
# Shellcheck should not follow sourced files.
# They will be linted individually.
# shellcheck disable=SC1090,SC1091

source lib/common.sh

CONFIG_PROFILE="$1"
source "$CONFIG_PROFILE"

function is_installed() {
    local package_name="$1"
    pacman -Q "$package_name" >/dev/null 2>&1
}

function install_pkgs() {
    log_subheader "Installing Packages"

    # The expansion of $PACKAGES should not be quoted. Pacman needs
    # word-splitting in order to interpret each invdividual package
    # rather than the entire string as a single package.
    # shellcheck disable=SC2086
    sudo pacman -Syu --noconfirm --needed $PACKAGES
}

function setup_network() {
    log_subheader "Network Setup"
    is_installed networkmanager && {
        log_info "Disabling dhcpcd and enabling NetworkManager service"
        sudo systemctl disable dhcpcd
        sudo systemctl enable NetworkManager.service
    }
}

function obtain_keys_for_aur() {
    log_subheader "Obtaining Keys for AUR Packages"
    if [[ "$AUR_PKGS" == *"dropbox"* ]]; then
        log_info "Fetching Dropbox Key"
        sudo  wget https://linux.dropbox.com/fedora/rpm-public-key.asc
        gpg --import rpm-public-key.asc    
    fi

    # Spotify AUR
    if [[ "$AUR_PKGS" == *"spotify"* ]]; then
        log_info "Fetching Spotify Key"
        gpg --recv-key D1742AD60D811D58
    fi
}

function install_aur_pkgs() {
    log_subheader "Installing AUR Packages"
    mkdir -p ~/.aur

    for A in "${AUR_PKGS[@]}"; do
        log_info "Installing $A"
        cd ~/.aur || exit
        git clone https://aur.archlinux.org/"$A".git
        cd "$A" || exit
        makepkg -si --noconfirm
    done
    cd ~/.install_scripts || exit
}

function customize_grub_theme() {
    log_subheader "Customizing GRUB"
    is_installed arch-silence-grub-theme-git && {
        log_info "Setting up arch-silence theme"
        sudo sed -i 's:#GRUB_THEME="/path/to/gfxtheme":GRUB_THEME="/boot/grub/themes/arch-silence/theme.txt":' /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg    
    }
}

function setup_desktop_environment() {
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

function copy_private_configs() {
    log_subheader "Copying Private Configs from USB"
    if [ "$USE_PRIVATE_CONFIGS" == "true" ]; then
        for entry in "${PRIVATE_CONFIGS[@]}"; do
            log_info "Copying $src_loc private configurations"
            IFS='|' read -ra item <<< "$entry"
            local src_loc=${item[0]}
            local dest_loc=${item[1]}
            cp -Rp private/"$src_loc" ~/"$dest_loc"
        done
        IFS=' '
    fi
}

function get_dotfiles() {
    if [ "$DOTFILES_REPO" != "" ]; then
        log_subheader "Dotfiles"
        cd ~ || exit
        log_info "Cloning dotfiles repo from $DOTFILES_REPO"
        git clone "$DOTFILES_REPO"
        cd dotfiles || exit
        log_info "Running dotfiles setup.sh"
        bash ./setup.sh
        cd ~ || exit
    fi
}



log_header "Customization"

install_pkgs
setup_network
obtain_keys_for_aur
install_aur_pkgs
customize_grub_theme
setup_desktop_environment
copy_private_configs
get_dotfiles

log_subheader "Customizations Complete!"