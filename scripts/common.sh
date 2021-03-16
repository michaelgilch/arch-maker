#!/bin/bash
#
# Library containing helper functions used throughout installation.

LOG_FILE="install.log"
TARGET="/mnt"
DEBUG=true

#------------------------------------------------------------------------------
# Shortens calls to chroot environment.
#
# Globals:
#   TARGET
# Arguments:
#   Command to execute in chroot environment
#------------------------------------------------------------------------------
function chr() {
    arch-chroot "$TARGET" "$@"
}

function init_log() {
    exec > >(tee -a $LOG_FILE)
    exec 2> >(tee -a $LOG_FILE >&2)

    if [ "$DEBUG" == true ]; then
        set -o xtrace
    fi
}

#---------------------------------------
# Checks if a package is installed
# Arguments:
#   Package to check
#---------------------------------------
function is_installed() {
    chr pacman -Q $1 >/dev/null 2>&1
}