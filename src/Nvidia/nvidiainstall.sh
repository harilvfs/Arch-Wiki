#!/bin/bash

# //////////////////////////////////////////////////////////////////////////////////////////
# Nvidiainstall by Justus0405
# Source : https://github.com/Justus0405/Arch-Wiki/blob/main/src/Nvidia/nvidiainstall.sh
# License: MIT
# //////////////////////////////////////////////////////////////////////////////////////////

VERSION="0.1-Experimental"

# Color variables
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
CYAN="\e[1;36m"
ENDCOLOR="\e[0m"

# Info variables
SUCCSESS="${GREEN}[✓]"
ERROR="${RED}Error:${ENDCOLOR}"
SECTION="${YELLOW}[!]"
INFO="${CYAN}[i]"

set -e  # Exit immediately if a command exits with a non-zero status
clear

# Function to handle script arguments
check_args() {
    while [[ "$1" != "" ]]; do
        case "$1" in
            -h | --help)
                echo -e "Usage: nvidiainstall.sh [options]"
                echo -e ""
                echo -e "Options:"
                echo -e "  -h, --help      Show this help message"
                echo -e "  -d, --debug     Run the script with logging"
                echo -e "  -f, --force     Disable nvidia check and force install"
                exit 0
                ;;
            -d | --debug)
                LOG_FILE="/var/log/nvidia_install.log"
                echo -e "${INFO} Running in debug mode.${ENDCOLOR}"
                DEBUG_MODE=true
                echo -e "${INFO} Started logging at $LOG_FILE${ENDCOLOR}"
                exec > >(tee -i "$LOG_FILE") 2>&1
                ;;
            -f | --force)
                echo -e "${INFO} Running in forced mode.${ENDCOLOR}"
                FORCED_MODE=true
                ;;
            *)
                echo -e "Unknown option: $1"
                echo -e "Use -h or --help for help."
                exit 0
                ;;
        esac
        shift
    done
}

# Function to check if script is run with sudo privileges
check_sudo() {
    if [[ "$EUID" -ne 0 ]]; then
        echo -e "${ERROR} This script must be run as root. Use sudo."
        exit 1
    fi

# Check if root is in the wheel group
    if ! groups root | grep -q "\bwheel\b"; then
        echo -e "${INFO} Root is not in the wheel group. Adding root to the wheel group.${ENDCOLOR}"
        usermod -aG wheel root

        if [[ $? -eq 0 ]]; then
            echo -e "${INFO} Root has been successfully added to the wheel group.${ENDCOLOR}"
        else
            echo -e "${ERROR} Failed to add root to the wheel group."
            exit 1
        fi
    else
        echo -e "${INFO} Root is already in the wheel group.${ENDCOLOR}"
    fi
}

# Function to check if NVIDIA card is present
check_nvidia() {
    if lspci | grep -i nvidia &>/dev/null; then
        echo -e "${GREEN}NVIDIA card detected.${ENDCOLOR}"
    else
        echo -e "${ERROR} No NVIDIA card detected."
        exit 1
    fi
}

# Function to display a logo on startup
show_logo() {
    cat <<"EOF"

  _   _       _     _ _       _           _        _ _
 | \ | |_   _(_) __| (_) __ _(_)_ __  ___| |_ __ _| | |
 |  \| \ \ / / |/ _` | |/ _` | | '_ \/ __| __/ _` | | |
 | |\  |\ V /| | (_| | | (_| | | | | \__ \ || (_| | | |
 |_| \_| \_/ |_|\__,_|_|\__,_|_|_| |_|___/\__\__,_|_|_|


EOF
    echo -e "By Justus0405"
    echo -e "Version: ${RED}$VERSION${ENDCOLOR}"
    GPU=$(lspci | grep -i 'nvidia' || true)
    if [[ -z "$GPU" ]]; then
        GPU="No NVIDIA card detected"
    fi
    echo -e "GPU    : $GPU"
    echo -e ""
}

# Confirmation prompt
confirm_proceed() {
    show_logo
    echo -e "${RED}Warning:${ENDCOLOR} This script is experimental and only supports Maxwell or newer. Use at your own risk!"
    echo -e "${INFO} ${ENDCOLOR}This script will install ${GREEN}NVIDIA${ENDCOLOR} drivers and modify system configurations.${ENDCOLOR}"
    read -rp "Do you want to proceed? (y/N): " confirm
    case "$confirm" in
        [yY][eE][sS]|[yY])
            echo -e "${GREEN}Proceeding with installation...${ENDCOLOR}"
            ;;
        *)
            echo -e "${RED}Installation cancelled.${ENDCOLOR}"
            exit 0
            ;;
    esac
}

# Update database and system
update_system() {
    echo -e "${SECTION} Updating system...${ENDCOLOR}"
    sudo pacman -Syyu
}

# Function to check kernel and kernel headers
check_kernel_headers() {
    kernel_version=$(uname -r)
    if [[ "$kernel_version" == *"zen"* ]]; then
        echo -e "${INFO} Detected kernel: zen${ENDCOLOR}"
        sudo pacman -S --needed --noconfirm linux-zen-headers
    elif [[ "$kernel_version" == *"lts"* ]]; then
        echo -e "${INFO} Detected kernel: lts${ENDCOLOR}"
        sudo pacman -S --needed --noconfirm linux-lts-headers
    elif [[ "$kernel_version" == *"hardened"* ]]; then
        echo -e "${INFO} Detected kernel: hardened${ENDCOLOR}"
        sudo pacman -S --needed --noconfirm linux-hardened-headers
    else
        echo -e "${INFO} Detected kernel: regular${ENDCOLOR}"
        sudo pacman -S --needed --noconfirm linux-headers
    fi
}

# Function to install the needed NVIDIA Packages
install_nvidia_packages() {
    echo -e "${SECTION} Installing NVIDIA packages...${ENDCOLOR}"
    sudo pacman -S --needed --noconfirm nvidia-dkms libglvnd nvidia-utils opencl-nvidia nvidia-settings lib32-nvidia-utils lib32-opencl-nvidia egl-wayland
}

# Function to configure mkinitcpio
configure_mkinitcpio() {
    echo -e "${SECTION} Configuring mkinitcpio...${ENDCOLOR}"
    MKINITCPIO_CONF="/etc/mkinitcpio.conf"

    if [[ -f $MKINITCPIO_CONF ]]; then
        # Backup existing configuration file if it exists
        sudo cp "$MKINITCPIO_CONF" "$MKINITCPIO_CONF.bak"
        echo -e "${SUCCSESS} Backup of $MKINITCPIO_CONF created.${ENDCOLOR}"

        # Remove any lines that are commented out and contain nothing
        echo -e "${INFO} Cleaning up $MKINITCPIO_CONF.${ENDCOLOR}"
        sudo sed -i '/^#/d;/^$/d' "$MKINITCPIO_CONF"

        if grep -q 'MODULES=.*nvidia' "$MKINITCPIO_CONF"; then
            echo -e "${INFO} Cleaning up existing NVIDIA modules.${ENDCOLOR}"
            # Remove any occurrences of nvidia-related modules
            sudo sed -i 's/\b\(nvidia\|nvidia_modeset\|nvidia_uvm\|nvidia_drm\)\b//g' "$MKINITCPIO_CONF"

            # Ensure exactly one space between words and no space after '(' or before ')'
            sudo sed -i 's/ ( /(/g; s/ )/)/g; s/( */(/; s/ *)/)/; s/ \+/ /g' "$MKINITCPIO_CONF"
        fi

        # Now, append the NVIDIA modules in the correct order if they are not already there
        if ! grep -q 'MODULES=.*nvidia nvidia_modeset nvidia_uvm nvidia_drm' "$MKINITCPIO_CONF"; then
            echo -e "${INFO} Adding NVIDIA modules in the correct order.${ENDCOLOR}"
            sudo sed -i 's/^MODULES=(\([^)]*\))/MODULES=(\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' "$MKINITCPIO_CONF"

            # Ensure exactly one space between words and no space after '(' or before ')'
            sudo sed -i 's/ ( /(/g; s/ )/)/g; s/( */(/; s/ *)/)/; s/ \+/ /g' "$MKINITCPIO_CONF"
        else
            echo -e "${INFO} NVIDIA modules are already present in the correct order.${ENDCOLOR}"
        fi

        # Removing kms hook if it exists
        if grep -q '\bkms\b' "$MKINITCPIO_CONF"; then
            echo -e "${INFO} Removing kms hook${ENDCOLOR}"
            sudo sed -i 's/\bkms \b//g' "$MKINITCPIO_CONF"
        else
            echo -e "${INFO} kms hook is not present.${ENDCOLOR}"
        fi

        echo -e "${SUCCSESS} mkinitcpio.conf updated.${ENDCOLOR}"
    else
        echo -e "${ERROR} $MKINITCPIO_CONF not found."
        exit 1
    fi
}

# Function to configure modprobe
configure_modprobe() {
    echo -e "${SECTION} Creating NVIDIA configuration file...${ENDCOLOR}"
    NVIDIA_CONF="/etc/modprobe.d/nvidia.conf"

    # Backup existing configuration file if it exists
    if [[ -f $NVIDIA_CONF ]]; then
        sudo cp "$NVIDIA_CONF" "${NVIDIA_CONF}.bak"
        echo -e "${SUCCSESS} Backup of $NVIDIA_CONF created.${ENDCOLOR}"
    fi

    # Create new configuration file
    if echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee "$NVIDIA_CONF" > /dev/null; then
        echo -e "${SUCCSESS} NVIDIA configuration file created.${ENDCOLOR}"
    else
        echo -e "${ERROR} Failed to create NVIDIA configuration file."
        exit 1
    fi
}

# Function to configure grub default
configure_grub_default() {
    echo -e "${SECTION} Configuring GRUB default...${ENDCOLOR}"
    GRUB_CONF="/etc/default/grub"

    if [[ -f $GRUB_CONF ]]; then
        # Backup existing configuration file if it exists
        sudo cp "$GRUB_CONF" "$GRUB_CONF.bak"
        echo -e "${SUCCSESS} Backup of $GRUB_CONF created.${ENDCOLOR}"

        # Update the GRUB configuration
        sudo sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/!b;/nvidia_drm.modeset=1/!s/\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)/\1 nvidia_drm.modeset=1/' "$GRUB_CONF"
    else
        echo -e "${ERROR} $GRUB_CONF not found."
        exit 1
    fi
}

# Function to regenerate initramfs
regenerate_initramfs() {
    echo -e "${SECTION} Regenerating initramfs...${ENDCOLOR}"
    sudo mkinitcpio -P
}

# Function to update the grub config
update_grub_config() {
    echo -e "${SECTION} Updating GRUB config...${ENDCOLOR}"
    sudo grub-mkconfig -o /boot/grub/grub.cfg
}

# Reboot confirmation prompt
confirm_reboot() {
    echo -e "${GREEN}Installation complete.${ENDCOLOR}"
    read -rp "Would you like to reboot now? (y/N): " reboot_now
    case "$reboot_now" in
        [yY][eE][sS]|[yY])
            sudo reboot now
            ;;
        *)
            echo -e "Please reboot your system later to apply changes."
            exit 0
            ;;
    esac
}

# Step 1: Check launch arguments for extra functionality
check_args "$@"

# Step 2: Check if running as sudo
check_sudo

# Step 3: Check if NVIDIA card is present
if [[ $FORCED_MODE != true ]]; then
    check_nvidia
fi

# Step 4: Ask for confirmation
confirm_proceed

# Step 5: Update database and system
update_system

# Step 6: Check kernel headers and install if needed
check_kernel_headers

# Step 7: Install NVIDIA Packages
install_nvidia_packages

# Step 8: Configure mkinitcpio
configure_mkinitcpio

# Step 9: Create NVIDIA Configuration File for modprobe
configure_modprobe

# Step 10: Configure GRUB default
configure_grub_default

# Step 11: Regenerate initramfs
regenerate_initramfs

# Step 12: Update GRUB config
update_grub_config

# Step 13: Reboot (optional)
confirm_reboot
