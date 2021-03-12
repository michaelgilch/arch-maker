#!/bin/bash
#
# Queries variables.sh, user, and hardware for configuration information.

source variables.sh

function get_hostname() {
    if [ "$HOST_NAME" == "" ]; then
        read -r -p "Hostname: " HOST_NAME
    fi
    echo "-> Hostname set to '$HOST_NAME'"
}

#------------------------------------------------------------------------------
# Obtains password for specified user
# Arguments:
#   user to prompt for password
#------------------------------------------------------------------------------
function get_password() {
    PW_1=""
    PW_2=""
    local user=$1
    local match=false
    while [ "$match" == false ]; do
        read -r -p "Enter password for $user: " -s PW_1
        echo
        read -r -p "Enter password for $user, again: " -s PW_2
        echo
        if [[ "$PW_1" != "$PW_2" ]]; then
            echo "ERROR: Passwords do not match."
        else
            match=true
        fi
    done
    echo "-> $user Password set."
}

function get_root_password() {
    if [ "$ROOT_PASSWORD" == "" ]; then
        get_password root
        ROOT_PASSWORD="$PW_1"
    fi
}

function get_primary_user() {
    if [ "$PRIMARY_USER" == "" ]; then
        read -r -p "Primary User Name: " PRIMARY_USER
    fi
    echo "-> Primary User set to '$PRIMARY_USER'."
}

function get_primary_user_password() {
    if [ "$PRIMARY_USER" != "" && "$PRIMARY_USER_PASSWORD" == "" ]; then
            get_password "$PRIMARY_USER"
            PRIMARY_USER_PASSWORD="$PW_1"
        fi
    fi
}

function get_is_virtualbox() {
    if [ "$IS_VIRTUALBOX" == "" ]; then
        IS_VIRTUALBOX="false"
        if [ -n "$(lspci | grep -i virtualbox)" ]; then
            IS_VIRTUALBOX="true"
        fi
    fi
    echo "-> Virtualbox Install set to '$IS_VIRTUALBOX'"
}

function get_is_intel_cpu() {
    if [ "$IS_INTEL_CPU" == "" ]; then
        IS_INTEL_CPU="false"
        if [ -n "$(lscpu | grep GenuineIntel)" ]; then
            IS_INTEL_CPU="true"
        fi
    fi    
    echo "-> Intel CPU set to '$IS_INTEL_CPU'"
}

function get_is_nvidia_graphics() {
    if [ "$IS_NVIDIA_GRAPHICS" == "" ]; then
        IS_NVIDIA_GRAPHICS="false"
        if [ -n "$(lspci | grep NVIDIA)" ]; then
            IS_NVIDIA_GRAPHICS="true"
        fi
    fi    
    echo "-> NVIDIA Graphics set to '$IS_NVIDIA_GRAPHICS'"
}

echo "Collecting configuration information..."

get_hostname
get_root_password
get_primary_user
get_primary_user_password
get_is_virtualbox
get_is_intel_cpu
get_is_nvidia_graphics
