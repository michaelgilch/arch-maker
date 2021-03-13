#!/bin/bash
#
# Customized package list for DaVinci

#--------------------------------------
# GUI
#--------------------------------------

# Display Server
PACKAGES+=" xorg-server xorg-xprop"

# Display Driver
PACKAGES+=" nvidia nvidia-settings nvidia-utils"

# Desktop Environment
PACKAGES+=""

# Window Manager
PACKAGES+=" openbox"

# Display Manager
PACKAGES+=" lxdm"

#--------------------------------------
# Utilities
#--------------------------------------

# Archive Management
PACKAGES+=" file-roller bzip2 gzip p7zip unrar unzip xz zip"

# Comparision Tools
PACKAGES+=" diffuse diff-so-fancy meld"

# File Managers
PACKAGES+=" pcmanfm"

# Shell Utilities
PACKAGES+=" bash-completion bc"

# Terminal Emulator
PACKAGES+=" terminator"

#--------------------------------------
# Utilities
#--------------------------------------

# Build Automation
PACKAGES+=" ant gradle"

# IDEs
#PACKAGES+=" intellij-idea-community-edition"

# Version Control
PACKAGES+=" git"

