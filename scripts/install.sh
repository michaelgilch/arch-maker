#!/bin/bash
#
# Main installation script for customized ArchLinux.
#
# The main body is modeled after the ArchLinux Installation Guide
# found at https://wiki.archlinux.org/index.php/Installation_guide.

source config.sh
source common.sh

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

function set_password() {
    local user="$1"
    local pw="$2"
    chr sh -c "echo '$user:$pw' | chpasswd"
}

function set_root_password() {
    set_password root "$ROOT_PASSWORD"
}

function add_user() {
    if [ "$PRIMARY_USER" != "" ]; then
        printf "\nAdding user %s...\n" "$PRIMARY_USER"
        chr useradd -m -G wheel -s /bin/bash "$PRIMARY_USER"
        set_password "$PRIMARY_USER" "$PRIMARY_USER_PASSWORD"
        sed -i "/%wheel ALL=(ALL) ALL/s/^# //" "$TARGET"/etc/sudoers
    fi
}

function copy_scripts() {
    cp  post-install.sh /mnt/home/"$PRIMARY_USER"
    cp -r post-install /mnt/home/"$PRIMARY_USER"
}

function enable_services() {
    chr systemctl enable lxdm.service
}

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
#copy_scripts
#enable_services

printf "\nBase installation complete."
