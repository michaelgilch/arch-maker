#!/bin/bash
#
# Global variables used throughout installation.

#------------------------------------------------------------------------------
#
# The following must be set prior to running install
#
#------------------------------------------------------------------------------
readonly TARGET="/mnt"
readonly MIRRORLIST_URL="https://archlinux.org/mirrorlist/?\
country=US&\
protocol=https&\
ip_version=4&\
use_mirror_status=on"
readonly MIRRORLIST_TEMP_FILE="/tmp/mirrorlist"
readonly MIRRORLIST_FINAL_FILE="/etc/pacman.d/mirrorlist"

# TODO: Move locale and timezone settings to prompt system
readonly LOCALE="en_US.UTF-8"
readonly TIME_ZONE="America/New_York"

#------------------------------------------------------------------------------
#
# The following, if left blank, will present prompts during install
#
#------------------------------------------------------------------------------
HOST_NAME=""
# If left blank here and at prompt, no primary user will be created.
PRIMARY_USER=""

#------------------------------------------------------------------------------
#
# The following should typically be left blank and will either 
# present prompts to the user or determined during installation.
#
#------------------------------------------------------------------------------
ROOT_PASSWORD=""
# Will only be prompted for PRIMARY_USER_PASSWORD if PRIMARY_USER is not empty
PRIMARY_USER_PASSWORD=""
IS_VIRTUALBOX=""
IS_INTEL_CPU=""
IS_NVIDIA_GRAPHICS=""
