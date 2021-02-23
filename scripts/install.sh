#!/bin/bash

readonly TARGET="/mnt"
readonly PRIMARY_USER="michael"
readonly HOST_NAME="DaVinci"

readonly MIRRORLIST_URL="https://archlinux.org/mirrorlist/?country=US&protocol=https&ip_version=4&use_mirror_status=on"
readonly MIRRORLIST_TEMP_FILE="/tmp/mirrorlist"
readonly MIRRORLIST_FINAL_FILE="/etc/pacman.d/mirrorlist"

readonly LOCALE="en_US.UTF-8"
readonly TIME_ZONE="America/New_York"

IS_VIRTUALBOX=""
IS_INTEL_CPU=""

source ./base_packages.conf

function chr() {
    arch-chroot "$TARGET" "$@"
}

function set_is_virtualbox() {
    if [ -n "$(lspci | grep -i virtualbox)" ]; then
        IS_VIRTUALBOX="true"
    fi
}

function set_is_intel_cpu() {
    if [ -n "$(lscpu | grep GenuineIntel)" ]; then
        IS_INTEL_CPU="true"
    fi
}

function get_hostname() {
    if [ "$HOST_NAME" == "" ]; then
        read -r -p "Enter Hostname: " HOST_NAME
        echo
    fi
}

function get_primary_user() {
    if [ "$PRIMARY_USER" == "" ]; then
        read -r -p "Enter Primary User Name: " PRIMARY_USER
        echo
    fi
}

function verify_network() {
    echo "Verifying network connectivity..."
    if ! ping -q -c 1 -W 1 google.com >/dev/null; then
        echo "ERROR: Network connection not available."
        exit 1
    fi
}

function set_system_clock() {
    echo "Setting system clock..."
    timedatectl set-ntp true
}

function update_mirrorlist() {
    echo "Updating mirrorlist..."
    curl -s "$MIRRORLIST_URL" > "$MIRRORLIST_TEMP_FILE"
    sed -i 's/#//' "$MIRRORLIST_TEMP_FILE"
    rankmirrors "$MIRRORLIST_TEMP_FILE" > "$MIRRORLIST_FINAL_FILE"
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
    chr grub-install /dev/sdd
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

function set_root_password() {
    echo "Setting root password..."
    match=false
    while [ "$match" == false ]; do
        read -r -p "Enter root password: " -s root_pw_1
        echo
        read -r -p "Enter root password, again: " -s root_pw_2
        echo
        if [[ "$root_pw_1" != "$root_pw_2" ]]; then
            echo "Passwords do not match."
        else
            match=true
        fi
    done
    chr sh -c "echo 'root:$root_pw_1' | chpasswd"
}

function add_user() {
    printf "\nAdding user %s...\n" "$PRIMARY_USER"
    chr useradd -m -G wheel -s /bin/bash "$PRIMARY_USER"
    printf "Password for %s: " "$PRIMARY_USER"
    read -r -s user_pw
    chr sh -c "echo '$PRIMARY_USER:$user_pw' | chpasswd"
    sed -i "/%wheel ALL=(ALL) ALL/s/^# //" "$TARGET"/etc/sudoers
}

verify_network
set_is_virtualbox
set_is_intel_cpu
set_system_clock
update_mirrorlist
pacstrap_system
generate_fstab
set_timezone
set_locale
enable_network
configure_bootloader
get_hostname
set_hostname
configure_initcpio
set_root_password
get_primary_user
add_user

printf "\nBase installation complete."
