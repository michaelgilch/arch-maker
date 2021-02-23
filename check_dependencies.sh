#!/bin/bash

# Verify dependences need for custom archiso build process are satisfied.

DEPENDENCY_PACKAGES_NEEDED=""

function check_dependency() {
    check="$pacman -Q "$1" 2>/dev/null)"
    if [ -z "${check}" ]; then
        DEPENDENCY_PACKAGES_NEEDED+=${1}" "
    fi
}

echo "Checking build dependencies..."

check_dependency archiso

# for testing
check_dependency qemu
check_dependency edk2-ovmf

if [ -n "${DEPENDENCY_PACKAGES_NEEDED}" ]; then
    echo "The following dependencies are missing:"
    echo "    ${DEPENDENCY_PACKAGES_NEEDED}"
    echo "> Install missing dependencies now? [y/N]: "
    read -r input
    case "$input" in
        y|Y)    sudo pacman -Sy ${DEPENDENCY_PACKAGES_NEEDED} ;;
        *)      echo "Error: Missing dependencies, exiting."; exit 1;;
    esac
else
    echo "All dependencies satisfied."
fi
