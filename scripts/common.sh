#!/bin/bash
#
# Library containing helper functions used during base installation.

LOG_FILE="install.log"
DEBUG=false

#---------------------------------------
# Shortens calls to arch-chroot environment.
# Globals:
#   TARGET
# Arguments:
#   Command to execute in chroot environment
#---------------------------------------
function chr() {
    arch-chroot "$TARGET" "$@"
}

#---------------------------------------
# Initializes Logging of Installation
# Globals:
#   LOG_FILE
#   DEBUG
# Outputs:
#   STDERR, STDOUT, [commands] to log file
#---------------------------------------
function init_log() {
    exec > >(tee -a $LOG_FILE)
    exec 2> >(tee -a $LOG_FILE >&2)

    if [ "$DEBUG" == true ]; then
        set -o xtrace
    fi
}