#!/bin/bash
#
# Packages for base install without customizations.
#
# Besides base, linux, and linux-firmware, which are called out by the 
# ArchLinux Wiki Installation Instructions, I have added a few packages
# that I need on every installation.

# Base
PACKAGES="base base-devel"

# Kernel
PACKAGES+=" linux linux-firmware"

# Boot Loader
PACKAGES+=" grub os-prober"

# Network
PACKAGES+=" dhcpcd"

# Utilities
PACKAGES+=" vim"
