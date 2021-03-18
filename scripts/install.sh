#!/bin/bash
#
# Main installation script for customized ArchLinux.
#
# This piece of the installation is modeled after the ArchLinux Installation
# Guide found at https://wiki.archlinux.org/index.php/Installation_guide.
# Following this script, customize.sh will be called to perform more fine-tuned
# customizations, installation of aur packages, sdkman, dotfiles, etc.

source common.sh

function load_config() {
    echo "Loading $1"
    source $1
    source config.sh
}

function setup_partitions() {
    mkfs.ext4 "$ROOT_PARTITION"
    mount "$ROOT_PARTITION" "$TARGET"

    for P in ${FORMAT_PARTITIONS[@]}; do
        IFS='|' S=(${P}) 
        PARTITION=${S[0]}
        MOUNT_POINT=${S[1]}
        FORMAT=${S[2]}
        
        mkfs."$FORMAT" "$PARTITION"
        mkdir -p "$MOUNT_POINT"
        mount "$PARTITION" "$MOUNT_POINT"
        IFS=' '
    done

    for P in ${MOUNT_PARTITIONS[@]}; do
        IFS='|' S=(${P})
        PARTITION=${S[0]}
        MOUNT_POINT=${S[1]}

        mkdir -p "$MOUNT_POINT"
        mount "$PARTITION" "$MOUNT_POINT"
        IFS=' '
    done
}

function verify_network() {
    echo "Verifying network connectivity..."
    if ! ping -q -c 1 -W 1 "$PING_HOSTNAME" >/dev/null; then
        echo "ERROR: Network connection not available."
        exit 1
    fi
}

function set_system_clock() {
    echo "Setting system clock..."
    timedatectl set-ntp true
}

function update_mirrorlist() {
    local temp_file="/tmp/mirrorlist"
    local final_file="/etc/pacman.d/mirrorlist"
    echo "Updating mirrorlist..."
    curl -s "$MIRRORLIST_URL" > "$temp_file"
    sed -i 's/#//' "$temp_file"
    rankmirrors "$temp_file" > "$final_file"
}

function pacstrap_system() {
    echo "Installing packages..."
    pacstrap "$TARGET" $(echo "$PACKAGES")
}

function generate_fstab() {
    echo "Generating fstab..."
    genfstab -U -p "$TARGET" >> "$TARGET"/etc/fstab
}

function set_timezone() {
    echo "Setting timezone..."
    chr ln -sf /usr/share/zoneinfo/"$TIME_ZONE" /etc/localtime
    chr hwclock --systohc
}

function set_locale() {
    echo "Setting locale..."
    sed -i -e "s/#$LOCALE/$LOCALE/" "$TARGET"/etc/locale.gen
    chr locale-gen
    echo LANG="$LOCALE" > "$TARGET"/etc/locale.conf
}

function enable_network() {
    echo "Enabling network..."
    chr systemctl enable dhcpcd.service
}

function configure_bootloader() {
    if [ "$IS_INTEL_CPU" == "true" -a "$IS_VIRTUALBOX" != "true" ]; then
        chr pacman -S intel-ucode --noconfirm
    fi
    chr grub-install --target=i386-pc --recheck "$BOOT_DISK"
    chr grub-mkconfig -o /boot/grub/grub.cfg
}

function set_hostname() {
    echo "Setting hostname..."
    echo "$HOST_NAME" > "$TARGET"/etc/hostname
}

function configure_initcpio() {
    echo "Configuring initcpio..."
    chr mkinitcpio -p linux
}

function set_password() {
    local user="$1"
    local pw="$2"
    chr sh -c "echo '$user:$pw' | chpasswd"
}

function set_root_password() {
    set_password root "$ROOT_PW"
}

function add_user() {
    if [ "$PRIMARY_USER" != "" ]; then
        printf "\nAdding user %s...\n" "$PRIMARY_USER"
        chr useradd -m -G wheel -s /bin/bash "$PRIMARY_USER"
        set_password "$PRIMARY_USER" "$PRIMARY_USER_PW"
        sed -i "/%wheel ALL=(ALL) ALL/s/^# //" "$TARGET"/etc/sudoers
    fi
}

init_log

if [ $# == 1 ]; then
    CONF_FILE="configs/${1,,}.conf"
    if [ -f "$CONF_FILE" ]; then
        CUSTOMIZE='true'
        load_config "$CONF_FILE"
    else
        echo "Configuration for $1 cannot be found. Exiting"
        exit 1
    fi
else
    load_config "configs/default.conf"
fi

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
set_root_password
add_user

if [ "$CUSTOMIZE" == 'true' ]; then
    # Temporarily disable sudo password
    sed -i 's/^%wheel ALL=(ALL) ALL$/%wheel ALL=(ALL) NOPASSWD: ALL/' /mnt/etc/sudoers

    # Copy scripts
    mkdir -p /mnt/home/"$PRIMARY_USER"/.install_scripts/
    cp customize.sh /mnt/home/"$PRIMARY_USER"/.install_scripts/
    cp -R configs /mnt/home/"$PRIMARY_USER"/.install_scripts/

    # Run customization script
    chr /bin/bash -c "su $PRIMARY_USER -l -s -c \"./.install_scripts/customize.sh .install_scripts/$CONF_FILE\""

    # Re-enable sudo password
    sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL$/%wheel ALL=(ALL) ALL/' /mnt/etc/sudoers
fi

printf "\nInstallation complete."
