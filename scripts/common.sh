#!/bin/bash
#
# Library containing helper functions used during base installation.

set -e

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

function log() {
    echo "$(date '+%F %T') $*"
}

function log_info() {
    local msg="[INFO] "
    if [ "$DEBUG" == "true" ]; then
        msg+="(${BASH_SOURCE[1]} - ${FUNCNAME[1]}:${BASH_LINENO[0]}) "
    fi
    msg+="$*"
    log $msg
}

function log_warn() {
    local msg="[WARNING] "
    if [ "$DEBUG" == "true" ]; then
        msg+="(${BASH_SOURCE[1]} - ${FUNCNAME[1]}:${BASH_LINENO[0]}) "
    fi
    msg+="$*"
    log $msg
}

function log_err() {
    local msg="[ERROR] "
    if [ "$DEBUG" == "true" ]; then
        msg+="(${BASH_SOURCE[1]} - ${FUNCNAME[1]}:${BASH_LINENO[0]}) "
    fi
    msg+="$*"
    log $msg
    exit 1
}

function log_header() {
    # make leading spaces for message
    local msg=""
    local len=${#1}
    let start_position=(40-$len)/2
    for (( i=0; i<$start_position; i++ )); do
        msg+=" "
    done
    msg+=$1

    echo "========================================"
    echo "$msg"
    echo "========================================"
}

#---------------------------------------
# Outputs a sub-heading for logging
# Arguments:
#   Header (descriptive section name)
# Outputs:
#   STDOUT
#---------------------------------------
function log_subheader() {
    # make leading spaces for message
    local msg=""
    local len=${#1}
    let start_position=(40-$len)/2
    for (( i=0; i<$start_position; i++ )); do
        msg+=" "
    done
    msg+=$1

    echo "----------------------------------------"
    echo "$msg"
    echo "----------------------------------------"
}
