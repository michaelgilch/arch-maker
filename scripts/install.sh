#!/bin/bash
#
# Entry Point of scripts for customized ArchLinux installation.
#
# This piece of the installation is modeled after the ArchLinux Installation
# Guide found at https://wiki.archlinux.org/index.php/Installation_guide.
# Following this script, customize.sh will be called to perform more fine-tuned
# customizations, installation of aur packages, sdkman, dotfiles, etc.
#
# Shellcheck should not follow sourced files.
# They will be linted individually.
# shellcheck disable=SC1090,SC1091

source common.sh

function usage() {
    echo "Arch-Maker Custom Build Scripts."
    echo
    echo "Syntax: $0 [-h] [CONFIG FILE]"
    echo
    echo "h     Print this help."
    echo 
    echo "CONFIG FILE - base name of configuration file in configs/"
    echo "  if not supplied, will use default configuration"
}

#---------------------------------------
# Loads a configuration file passed to the script or the default configuration
# Globals: 
#   CONF_FILE
#   CUSTOMIZE
# Arguments:
#   [optional] Configuration name
#---------------------------------------
function load_config() {
    if [ $# == 1 ]; then
        CONF_FILE="configs/${1,,}.conf"

        if [ -f "$CONF_FILE" ]; then
            CUSTOMIZE='true'
            source "$CONF_FILE"
        else
            log_err "Configuration file $CONF_FILE cannot be found. Aborting..."
        fi
    else
        CONF_FILE="configs/default.conf"
        CUSTOMIZE='false'
        source "configs/default.conf"
    fi

    log_info "Config: $CONF_FILE"
    source config.sh
}

#---------------------------------------
# Formats and mounts partitions needed for installation
# Globals:
#   ROOT_PARTITION
#   TARGET
#   FORMAT_PARITIONS
#   MOUNT_PARITIONS
#---------------------------------------
function setup_partitions() {
    log_subheader "Setup Partitions"

    log_info "Unmounting any previously mounted partitions"
    for entry in "${FORMAT_PARTITIONS[@]}"; do
        IFS='|' read -ra item <<< "$entry"
        PARTITION=${item[0]}
        umount "$PARTITION"
    done

    for entry in "${MOUNT_PARTITIONS[@]}"; do
        IFS='|' read -ra item <<< "$entry"
        PARTITION=${item[0]}
        umount "$PARTITION"
    done

    umount "$ROOT_PARTITION"

    log_info "Formatting Root Partition $ROOT_PARTITION"
    mkfs.ext4 "$ROOT_PARTITION"
    log_info "Mounting $ROOT_PARTITION to $TARGET"
    mount "$ROOT_PARTITION" "$TARGET"

    for entry in "${FORMAT_PARTITIONS[@]}"; do
        IFS='|' read -ra item <<< "$entry"
        PARTITION=${item[0]}
        MOUNT_POINT=${item[1]}
        FORMAT=${item[2]}
        
        log_info "Formatting $PARTITION as $FORMAT for $MOUNT_POINT"
        mkfs."$FORMAT" "$PARTITION"
        mkdir -p "$MOUNT_POINT"
        log_info "Mounting $PARTITION to $MOUNT_POINT"
        mount "$PARTITION" "$MOUNT_POINT"
        IFS=' '
    done

    for entry in "${MOUNT_PARTITIONS[@]}"; do
        IFS='|' read -ra item <<< "$entry"
        PARTITION=${item[0]}
        MOUNT_POINT=${item[1]}

        mkdir -p "$MOUNT_POINT"
        log_info "Mounting $PARTITION to $MOUNT_POINT"
        mount "$PARTITION" "$MOUNT_POINT"
        IFS=' '
    done
}

function verify_network() {
    log_subheader "Network Connectivity"
    if ! ping -q -c 1 -W 1 "$PING_HOSTNAME" >/dev/null; then
        log_err "Network connection not available."
    fi
    log_info "Network is active"
}

function set_system_clock() {
    log_subheader "System clock"
    log_info "Setting Date/Time to NTP"
    timedatectl set-ntp true
}

function update_mirrorlist() {
    log_subheader "Mirrorlist"
    local temp_file="/tmp/mirrorlist"
    local final_file="/etc/pacman.d/mirrorlist"
    log_info "Fetching mirrorlist from $MIRRORLIST_URL"
    curl -s "$MIRRORLIST_URL" > "$temp_file"
    sed -i 's/#//' "$temp_file"
    log_info "Ranking mirrors"
    rankmirrors "$temp_file" > "$final_file"
}

function pacstrap_system() {
    log_subheader "Bootstrapping System with pacstrap"
    if [ "$IS_INTEL_CPU" == "true" ] && [ "$IS_VIRTUALBOX" != "true" ]; then
        log_info "Adding intel_ucode to package list for pacstrap"
        BASE_PKGS+=" intel-ucode"
    fi
    log_info "Installing packages..." 

    # The expansion of $BASE_PKGS should not be quoted. Pacstrap needs
    # word-splitting in order to interpret each invdividual package
    # rather than the entire string as a single package.
    # shellcheck disable=SC2086
    pacstrap "$TARGET" $BASE_PKGS
}

function generate_fstab() {
    log_subheader "Generating fstab"
    genfstab -U -p "$TARGET" >> "$TARGET"/etc/fstab

    # ${TARGET} is already quoted with the full command.
    # TODO: Figure out a better way to handle
    # shellcheck disable=SC2086
    log_info "fstab set to:$(echo && cat ${TARGET}/etc/fstab)"
}

function set_timezone() {
    log_subheader "Timezone"
    log_info "Setting timezone to $TIMEZONE"
    chr ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
    log_info "Setting hardware clock"
    chr hwclock --systohc
}

function set_locale() {
    log_subheader "Locale"
    log_info "Setting locale to $LOCALE"
    sed -i -e "s/#$LOCALE/$LOCALE/" "$TARGET"/etc/locale.gen
    chr locale-gen
    log_info "Setting language to $LOCALE"
    echo LANG="$LOCALE" > "$TARGET"/etc/locale.conf
}

function enable_network() {
    log_subheader "Network"
    log_info "Enabling network with dhcpcd"
    chr systemctl enable dhcpcd.service
}

function configure_bootloader() {
    log_subheader "Bootloader"
    log_info "Configuring GRUB on $BOOT_DISK"
    chr grub-install --target=i386-pc --recheck "$BOOT_DISK"
    chr grub-mkconfig -o /boot/grub/grub.cfg
}

function set_hostname() {
    log_subheader "Hostname"
    log_info "Setting hostname to $HOST_NAME"
    echo "$HOST_NAME" > "$TARGET"/etc/hostname
}

function configure_initcpio() {
    log_subheader "mkinitcpio"
    echo "Configuring initcpio..."
    chr mkinitcpio -p linux
}

function set_password() {
    local user="$1"
    local pw="$2"
    log_info "Setting password for $user"
    chr sh -c "echo '$user:$pw' | chpasswd"
}

function set_root_password() {
    set_password root "$ROOT_PW"
}

function add_user() {
    if [ "$PRIMARY_USER" != "" ]; then
        log_info "Adding user $PRIMARY_USER to system"
        chr useradd -m -G wheel -s /bin/bash "$PRIMARY_USER"
        set_password "$PRIMARY_USER" "$PRIMARY_USER_PW"
        log_info "Adding sudo permissions to wheel group"
        sed -i "s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" "$TARGET"/etc/sudoers
    else
        log_warn "No Primary User Specified"
    fi
}

while getopts ":h" option; do
    case $option in
        h)  # Display help
            usage
            exit;;
        *)  usage
            exit;;
    esac
done


init_log #"$INSTALL_LOG_FILE"

log_header "Starting Arch-Maker Custom Installer"
log_info "Log File: $LOG_FILE"
log_info "Debug: $DEBUG"

if [ $# == 1 ]; then
    load_config "$1"
else
    load_config
fi

log_header "Installation"

setup_partitions
verify_network
set_system_clock
update_mirrorlist
pacstrap_system
generate_fstab
set_timezone
set_locale
enable_network
configure_bootloader
set_hostname
configure_initcpio

log_subheader "Users and Passwords"
set_root_password
add_user

if [ "$CUSTOMIZE" == 'true' ]; then

    log_subheader "Configure Customization"

    # Temporarily disable sudo password
    log_info "Temporarily disabling sudo password requirement"
    sed -i 's/^%wheel ALL=(ALL) ALL$/%wheel ALL=(ALL) NOPASSWD: ALL/' /mnt/etc/sudoers

    # Copy scripts
    log_info "Copying customization scripts to $PRIMARY_USER's account"
    mkdir -p /mnt/home/"$PRIMARY_USER"/.install_scripts/
    cp common.sh /mnt/home/"$PRIMARY_USER"/.install_scripts/
    cp customize.sh /mnt/home/"$PRIMARY_USER"/.install_scripts/
    cp -R configs /mnt/home/"$PRIMARY_USER"/.install_scripts/


    if [ "$USE_PRIVATE_CONFIGS" == "true" ]; then
        log_info "Configuring use of Private USB Configurations"
        mkdir /mnt/home/"$PRIMARY_USER"/.install_scripts/private
        cp -Rp tmp/* /mnt/home/"$PRIMARY_USER"/.install_scripts/private/
    fi

    chr chown -R "$PRIMARY_USER":"$PRIMARY_USER" /home/"$PRIMARY_USER"/.install_scripts

    # Run customization script
    log_info "Executing customizations as $PRIMARY_USER in chroot"
    chr /bin/bash -c "su $PRIMARY_USER -l -c \"cd .install_scripts && ./customize.sh ./$CONF_FILE\""

    # Re-enable sudo password
    log_info "Re-enabling sudo password requirement"
    sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL$/%wheel ALL=(ALL) ALL/' /mnt/etc/sudoers
fi

# Copying install log to installation
log_info "Copying installation log ($LOG_FILE) to /home/$PRIMARY_USER/.install_scripts/"
log_header "Installation complete."
cp install.log /mnt/home/"$PRIMARY_USER"/.install_scripts/

