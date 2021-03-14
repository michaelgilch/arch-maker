#!/bin/bash
#
# Library containing helper functions used throughout installation.

LOG_FILE="install.log"
TARGET="/mnt"
DEBUG=false

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