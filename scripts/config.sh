#!/bin/bash
#
# Library used to obtain information for the installation.
#
# Sources of information include, in order:
#   - Configuration File
#   - Hardware Probes
#   - User Prompts
# 
# An entry in a configuration file will will take precidence over a user
# prompt and/or hardware probe, preventing the latter from occuring.

source common.sh

#---------------------------------------
# Prompts user for locale if it does not exist in config file.
# Globals:
#   LOCALE
#---------------------------------------
function get_locale() {
    if [ "$LOCALE" == "" ]; then
        read -r -p "-> Locale (eg: 'en_US.UTF-8'): " LOCALE
    fi
    log_info "Locale set to '$LOCALE'"
}

#---------------------------------------
# Prompts user for timezone if it does not exist in config file.
# Globals:
#   TIMEZONE
#---------------------------------------
function get_timezone() {
    if [ "$TIMEZONE" == "" ]; then
        read -r -p "-> Timezone (eg: 'America/New_York'): " TIMEZONE
    fi
    log_info "Timezone set to '$TIMEZONE'"
}

#---------------------------------------
# Prompts user for hostname if it does not exist in configuration file.
# Globals:
#   HOST_NAME
#---------------------------------------
function get_hostname() {
    if [ "$HOST_NAME" == "" ]; then
        read -r -p "-> Hostname: " HOST_NAME
    fi
    log_info "Hostname set to '$HOST_NAME'"
}

#---------------------------------------
# Obtains password for specified user.
# Globals: 
#   PW_1, PW_2
# Arguments:
#   Username to prompt for password
#---------------------------------------
function get_password() {
    PW_1=""
    PW_2=""
    local user=$1
    local match=false
    while [ "$match" == false ]; do
        read -r -p "-> Enter password for $user: " -s PW_1
        echo
        read -r -p "-> Enter password for $user, again: " -s PW_2
        echo
        if [[ "$PW_1" == "$PW_2" ]]; then
            match=true
        else
            log_warn "Passwords do not match. Please try again."
        fi
    done
    log_info "Password for $user has been set."
}

#---------------------------------------
# Helper to obtain password for root user.
# Globals:
#   ROOT_PW
#---------------------------------------
function get_root_password() {
    if [ "$ROOT_PW" == "" ]; then
        get_password root
        ROOT_PW="$PW_1"
    fi
}

#---------------------------------------
# Obtains primary username if not set in config file.
# Globals:
#   PRIMARY_USER
#---------------------------------------
function get_primary_user() {
    if [ "$PRIMARY_USER" == "" ]; then
        read -r -p "-> Primary User Name: " PRIMARY_USER
    fi
    log_info "Primary User set to '$PRIMARY_USER'."
}

#---------------------------------------
# Helper to obtain password for primary user.
# Globals:
#   PRIMARY_USER
#   PRIMARY_USER_PW
#---------------------------------------
function get_primary_user_password() {
    if [ "$PRIMARY_USER" != "" ]; then
        if [ "$PRIMARY_USER_PW" == "" ]; then
            get_password "$PRIMARY_USER"
            PRIMARY_USER_PW="$PW_1"
        fi
    fi
}

#---------------------------------------
# Determines if installation is virtual, if not set in config file.
# Globals:
#   IS_VIRTUALBOX
#---------------------------------------
function get_is_virtualbox() {
    if [ "$IS_VIRTUALBOX" == "" ]; then
        IS_VIRTUALBOX="false"
        if lspci | grep -qi virtualbox; then
            IS_VIRTUALBOX="true"
        fi
    fi
    log_info "Virtualbox Install set to '$IS_VIRTUALBOX'"
}

#---------------------------------------
# Determines if CPU is Intel, if not set in config file.
# Globals:
#   IS_INTEL_CPU
#---------------------------------------
function get_is_intel_cpu() {
    if [ "$IS_INTEL_CPU" == "" ]; then
        IS_INTEL_CPU="false"
        if lscpu | grep -qi GenuineIntel; then
            IS_INTEL_CPU="true"
        fi
    fi    
    log_info "Intel CPU set to '$IS_INTEL_CPU'"
}

#---------------------------------------
# Determines if graphics card is NVIDIA, if not set in config file.
# Globals:
#   IS_NVIDIA_GRAPHICS
#---------------------------------------
function get_is_nvidia_graphics() {
    if [ "$IS_NVIDIA_GRAPHICS" == "" ]; then
        IS_NVIDIA_GRAPHICS="false"
        if lspci | grep -qi NVIDIA; then
            IS_NVIDIA_GRAPHICS="true"
        fi
    fi    
    log_info "NVIDIA Graphics set to '$IS_NVIDIA_GRAPHICS'"
}

#---------------------------------------
# Mounts private configs USB
# Globals:
#   USE_PRIVATE_CONFIGS
#---------------------------------------
function get_secret_usb() {
    if [ "$USE_PRIVATE_CONFIGS" == "true" ]; then
        echo "-> Insert USB with Private Configs"
        read -p "-> Press any key to continue..."
        local try_again="y"
        local found="false"
        until [ "$try_again" == "n" ]; do
            local private_usb=$(blkid | grep "LABEL=\"PRIVATE\"" | cut -d":" -f1)
            if [ -z "$private_usb" ]; then
                log_warn "Cannot find Private USB Device. Retry (Y|n): "
                read -r try_again
            else
                mkdir tmp
                log_info "Mounting $private_usb to tmp"
                mount "$private_usb" tmp
                try_again="n"
                found="true"
            fi
        done
        if [ "$found" == "false" ]; then
            USE_PRIVATE_CONFIGS="false"
            log_warn "Not using private config USB."
        fi
    fi
}

log_header "Configuration"

get_hostname
get_locale
get_timezone
get_root_password
get_primary_user
get_primary_user_password
get_is_virtualbox
get_is_intel_cpu
get_is_nvidia_graphics
get_secret_usb