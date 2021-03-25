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

function main() {
    log_header "Post-Install"

    bash post-install/packages.sh "$CONFIG_PROFILE"
    bash post-install/customizations.sh "$CONFIG_PROFILE"

    log_subheader "Customizations Complete!"    
}

main
