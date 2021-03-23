#!/bin/bash
#
# Customizations after base install
#
# Shellcheck should not follow sourced files.
# They will be linted individually.
# shellcheck disable=SC1090,SC1091

source common.sh

CONFIG_PROFILE="$1"
source "$CONFIG_PROFILE"

function is_installed() {
    local package_name="$1"
    pacman -Q "$package_name" >/dev/null 2>&1
}

function setup_network() {

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

}


log_header "Post-Install"

bash post-install/packages.sh "$CONFIG_PROFILE"

bash post-install/customizations.sh "$CONFIG_PROFILE"

log_subheader "Customizations Complete!"