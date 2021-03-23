#!/bin/bash
#
# Post-Base-Install script to add additional packages
#
# Shellcheck should not follow sourced files.
# They will be linted individually.
# shellcheck disable=SC1090,SC1091

source ~/.install_scripts/common.sh

CONFIG_PROFILE="$1"
source ~/.install_scripts/"$CONFIG_PROFILE"

function install_pkgs() {
    log_subheader "Installing Packages"

    # The expansion of $PACKAGES should not be quoted. Pacman needs
    # word-splitting in order to interpret each invdividual package
    # rather than the entire string as a single package.
    # shellcheck disable=SC2086
    sudo pacman -Syu --noconfirm --needed $PACKAGES
}

function aur_keys() {
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

    # The expansion of $AUR_PKGS should not be quoted. 
    # Word-splitting in order to interpret each invdividual package
    # rather than the entire string as a single package.
    # shellcheck disable=SC2086
    for A in ${AUR_PKGS[@]}; do
        log_info "Installing $A"
        cd ~/.aur || exit
        git clone https://aur.archlinux.org/"$A".git
        cd "$A" || exit
        makepkg -si --noconfirm
    done
    cd ~/.install_scripts || exit
}

function install_sublime_text() {
    log_subheader "Installing Sublime-Text-3"

    bash post-install/sublime.sh
}

function main() {
    log_header "Additional Packages"    

    if [ "$PACKAGES" != "" ]; then
        install_pkgs
    fi

    if [ "$AUR_PKGS" != "" ]; then
        aur_keys
        install_aur_pkgs
    fi

    install_sublime_text
}

main
