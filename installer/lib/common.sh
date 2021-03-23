#!/bin/bash
#
# Library containing helper functions used during base installation and customization.

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

#---------------------------------------
# Helper function for including a date/time stamp on all info, warning, and error logs
# Outputs:
#   STDOUT
#---------------------------------------
function log() {
    echo "$(date '+%F %T') $*"
}

#---------------------------------------
# Outputs an info log message and exits
# Globals:
#   DEBUG
#---------------------------------------
function log_info() {
    local msg="[INFO] "
    if [ "$DEBUG" == "true" ]; then
        msg+="(${BASH_SOURCE[1]} - ${FUNCNAME[1]}:${BASH_LINENO[0]}) "
    fi
    msg+="$*"
    log "$msg"
}

#---------------------------------------
# Outputs a warning log message
# Globals:
#   DEBUG
#---------------------------------------
function log_warn() {
    local msg="[WARNING] "
    if [ "$DEBUG" == "true" ]; then
        msg+="(${BASH_SOURCE[1]} - ${FUNCNAME[1]}:${BASH_LINENO[0]}) "
    fi
    msg+="$*"
    log "$msg"
}

#---------------------------------------
# Outputs an error log message and exits
# Globals:
#   DEBUG
#---------------------------------------
function log_err() {
    local msg="[ERROR] "
    if [ "$DEBUG" == "true" ]; then
        msg+="(${BASH_SOURCE[1]} - ${FUNCNAME[1]}:${BASH_LINENO[0]}) "
    fi
    msg+="$*"
    log "$msg"
    exit 1
}

#---------------------------------------
# Outputs a Heading for organized logging
# Arguments:
#   Header (descriptive section name)
# Outputs:
#   STDOUT
#---------------------------------------
function log_header() {
    local msg=""
    local len=${#1}
    local start_position=$(( (40-len) / 2 ))
    for (( i=0; i<start_position; i++ )); do
        msg+=" "
    done
    msg+=$1

    echo "========================================"
    echo "$msg"
    echo "========================================"
}

#---------------------------------------
# Outputs a sub-heading for organized logging
# Arguments:
#   SubHeader (descriptive section name)
# Outputs:
#   STDOUT
#---------------------------------------
function log_subheader() {
    local msg=""
    local len=${#1}
    local start_position=$(( (40-len) / 2 ))
    for (( i=0; i<start_position; i++ )); do
        msg+=" "
    done
    msg+=$1

    echo "----------------------------------------"
    echo "$msg"
    echo "----------------------------------------"
}
