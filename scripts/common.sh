#!/bin/bash
#
# Library containing helper functions used throughout installation.

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