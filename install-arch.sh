#!/bin/bash

# Arch Linux Installation Script for MSI Laptop
# System: Intel Core Ultra 7 155H, Intel Arc + NVIDIA RTX 3050, Killer Wi-Fi 7
# Based on: https://wiki.archlinux.org/title/Installation_guide

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
HOSTNAME="swiftarch"
USERNAME="swiftarch"
PASSWORD="1706"
TIMEZONE="Europe/London"
KEYMAP="uk"
LOCALE="en_GB.UTF-8"
SWAP_SIZE="16G"

# Partition variables (will be set by user)
ROOT_PART=""
HOME_PART=""
SHARED_PART=""
EFI_PART=""

# Logging function
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
        exit 1
    fi
}

# Verify UEFI boot mode
verify_uefi() {
    log "Verifying UEFI boot mode..."
    if [[ ! -d /sys/firmware/efi ]]; then
        error "System is not booted in UEFI mode. Please boot in UEFI mode."
        exit 1
    fi
    
    UEFI_SIZE=$(cat /sys/firmware/efi/fw_platform_size 2>/dev/null || echo "unknown")
    if [[ "$UEFI_SIZE" == "64" ]]; then
        log "UEFI 64-bit detected"
    elif [[ "$UEFI_SIZE" == "32" ]]; then
        warn "UEFI 32-bit detected (IA32)"
    else
        error "Could not determine UEFI bitness"
        exit 1
    fi
}

# Set keyboard layout
set_keyboard() {
    log "Setting keyboard layout to UK..."
    loadkeys "$KEYMAP" || {
        error "Failed to set keyboard layout. Available layouts:"
        localectl list-keymaps
        exit 1
    }
}

# Connect to internet
check_internet() {
    log "Checking internet connection..."
    if ! ping -c 1 -W 5 archlinux.org &>/dev/null; then
        error "No internet connection detected."
        warn "Please connect to the internet:"
        warn "  - Ethernet: Plug in cable"
        warn "  - Wi-Fi: Run 'iwctl' and connect"
        warn "  Then run this script again."
        exit 1
    fi
    log "Internet connection verified"
}

# Update system clock
update_clock() {
    log "Updating system clock..."
    timedatectl set-ntp true
    log "System clock synchronized"
}

# List partitions and get user input
detect_partitions() {
    log "Detecting partitions..."
    echo ""
    echo "Current disk layout:"
    lsblk -f
    echo ""
    warn "IMPORTANT: Identify your partitions carefully!"
    warn "Windows partitions (C: drive, recovery) should NOT be selected"
    echo ""
    
    # Find EFI partition (usually ~300MB FAT32)
    log "Looking for EFI partition..."
    EFI_CANDIDATES=$(lsblk -n -o NAME,SIZE,FSTYPE | grep -E "FAT|vfat" | grep -E "300M|256M|512M" || true)
    if [[ -z "$EFI_CANDIDATES" ]]; then
        warn "Could not auto-detect EFI partition. Please enter manually."
    else
        echo "Possible EFI partitions found:"
        echo "$EFI_CANDIDATES"
    fi
    
    echo ""
    read -p "Enter EFI partition (e.g., /dev/nvme0n1p1): " EFI_PART
    read -p "Enter ROOT partition (100GB, will be formatted to ext4): " ROOT_PART
    read -p "Enter HOME partition (150GB, will be formatted to ext4): " HOME_PART
    read -p "Enter SHARED partition (50GB, NTFS): " SHARED_PART
    
    # Verify partitions exist
    for part in "$EFI_PART" "$ROOT_PART" "$HOME_PART" "$SHARED_PART"; do
        if [[ ! -b "$part" ]]; then
            error "Partition $part does not exist!"
            exit 1
        fi
    done
    
    # Safety check - warn if partitions seem wrong
    ROOT_SIZE=$(lsblk -b -n -o SIZE "$ROOT_PART" | awk '{print int($1/1024/1024/1024)}')
    HOME_SIZE=$(lsblk -b -n -o SIZE "$HOME_PART" | awk '{print int($1/1024/1024/1024)}')
    
    if [[ $ROOT_SIZE -lt 50 || $ROOT_SIZE -gt 150 ]]; then
        warn "Root partition size ($ROOT_SIZE GB) seems unusual. Continue? (y/N)"
        read -r response
        [[ "$response" =~ ^[Yy]$ ]] || exit 1
    fi
    
    if [[ $HOME_SIZE -lt 50 || $HOME_SIZE -gt 200 ]]; then
        warn "Home partition size ($HOME_SIZE GB) seems unusual. Continue? (y/N)"
        read -r response
        [[ "$response" =~ ^[Yy]$ ]] || exit 1
    fi
    
    echo ""
    warn "WARNING: The following partitions will be FORMATTED:"
    warn "  Root: $ROOT_PART (will become ext4)"
    warn "  Home: $HOME_PART (will become ext4)"
    warn "  Shared: $SHARED_PART (will become NTFS)"
    warn "  EFI: $EFI_PART (will be MOUNTED ONLY, not formatted)"
    echo ""
    read -p "Continue with formatting? (yes/no): " confirm
    if [[ "$confirm" != "yes" ]]; then
        log "Installation cancelled"
        exit 0
    fi
}

# Format partitions
format_partitions() {
    log "Formatting partitions..."
    
    log "Formatting root partition ($ROOT_PART) to ext4..."
    mkfs.ext4 -F "$ROOT_PART"
    
    log "Formatting home partition ($HOME_PART) to ext4..."
    mkfs.ext4 -F "$HOME_PART"
    
    log "Formatting shared partition ($SHARED_PART) to NTFS..."
    if command -v mkfs.ntfs &>/dev/null; then
        mkfs.ntfs -F "$SHARED_PART"
    else
        warn "mkfs.ntfs not available in live environment"
        warn "Checking if partition is already NTFS..."
        if blkid -s TYPE -o value "$SHARED_PART" | grep -qi "ntfs"; then
            warn "Partition is already NTFS - will use as-is"
        else
            error "Cannot format to NTFS. Install ntfs-3g and format manually after installation."
            warn "You can continue, but shared partition will need manual setup"
        fi
    fi
    
    log "Partitions formatted successfully"
}

# Mount file systems
mount_filesystems() {
    log "Mounting file systems..."
    
    # Mount root
    mount "$ROOT_PART" /mnt
    
    # Create and mount home
    mkdir -p /mnt/home
    mount "$HOME_PART" /mnt/home
    
    # Mount EFI (create boot/efi directory)
    mount --mkdir "$EFI_PART" /mnt/boot/efi
    
    # Create shared mount point (will be configured in fstab)
    mkdir -p /mnt/shared
    
    log "File systems mounted"
}

# Install base system
install_base() {
    log "Installing base system and essential packages..."
    
    # Update mirrorlist (optional - use reflector for UK mirrors)
    log "Updating mirrorlist for UK..."
    if command -v reflector &>/dev/null; then
        reflector --country "United Kingdom" --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    else
        warn "reflector not available, using default mirrors"
    fi
    
    # Install base packages optimized for hardware
    pacstrap -K /mnt \
        base \
        linux \
        linux-firmware \
        intel-ucode \
        ntfs-3g \
        networkmanager \
        iwd \
        mesa \
        vulkan-intel \
        intel-media-driver \
        libva-intel-driver \
        nvidia \
        nvidia-utils \
        nvidia-settings \
        plasma \
        plasma-wayland-session \
        wayland \
        xorg-xwayland \
        sddm \
        pipewire \
        pipewire-pulse \
        pipewire-alsa \
        pipewire-jack \
        grub \
        efibootmgr \
        os-prober \
        nano \
        vim \
        man-db \
        man-pages \
        texinfo \
        sudo
    
    log "Base system installed"
}

# Generate fstab
generate_fstab() {
    log "Generating fstab..."
    genfstab -U /mnt >> /mnt/etc/fstab
    
    # Add shared partition to fstab
    SHARED_UUID=$(blkid -s UUID -o value "$SHARED_PART" 2>/dev/null || echo "")
    if [[ -n "$SHARED_UUID" ]]; then
        echo "" >> /mnt/etc/fstab
        echo "# Shared NTFS partition" >> /mnt/etc/fstab
        echo "UUID=$SHARED_UUID /mnt/shared ntfs-3g defaults,uid=1000,gid=1000,umask=022 0 0" >> /mnt/etc/fstab
        log "Shared partition added to fstab"
    else
        warn "Could not get UUID for shared partition - will need manual fstab entry"
        warn "After installation, add to /etc/fstab:"
        warn "  UUID=<UUID> /mnt/shared ntfs-3g defaults,uid=1000,gid=1000,umask=022 0 0"
    fi
    
    log "Fstab generated"
}

# Configure system (chrooted)
configure_system() {
    log "Configuring system (chrooted)..."
    
    # Timezone
    arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    arch-chroot /mnt hwclock --systohc
    
    # Locale
    sed -i "s/#$LOCALE/$LOCALE/" /mnt/etc/locale.gen
    arch-chroot /mnt locale-gen
    echo "LANG=$LOCALE" > /mnt/etc/locale.conf
    
    # Keyboard layout
    echo "KEYMAP=$KEYMAP" > /mnt/etc/vconsole.conf
    
    # Hostname
    echo "$HOSTNAME" > /mnt/etc/hostname
    
    # Hosts file
    cat >> /mnt/etc/hosts <<EOF
127.0.0.1	localhost
::1		localhost
127.0.1.1	$HOSTNAME.localdomain	$HOSTNAME
EOF
    
    # Root password
    log "Setting root password..."
    arch-chroot /mnt bash -c "echo 'root:$PASSWORD' | chpasswd"
    
    # Create swap file
    log "Creating swap file ($SWAP_SIZE)..."
    arch-chroot /mnt fallocate -l $SWAP_SIZE /swapfile || arch-chroot /mnt dd if=/dev/zero of=/swapfile bs=1M count=16384
    arch-chroot /mnt chmod 600 /swapfile
    arch-chroot /mnt mkswap /swapfile
    arch-chroot /mnt swapon /swapfile
    echo "/swapfile none swap defaults 0 0" >> /mnt/etc/fstab
    
    # Enable NetworkManager
    arch-chroot /mnt systemctl enable NetworkManager.service
    
    # Enable SDDM
    arch-chroot /mnt systemctl enable sddm.service
    
    log "System configured"
}

# Configure GRUB
configure_grub() {
    log "Configuring GRUB bootloader..."
    
    # Install GRUB
    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
    
    # Enable os-prober for Windows detection
    sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /mnt/etc/default/grub
    
    # Generate GRUB config
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
    
    log "GRUB configured (Windows should be detected)"
}

# Configure NVIDIA hybrid graphics
configure_nvidia() {
    log "Configuring NVIDIA hybrid graphics..."
    
    # Create NVIDIA Xorg config for PRIME
    mkdir -p /mnt/etc/X11/xorg.conf.d
    cat > /mnt/etc/X11/xorg.conf.d/10-nvidia.conf <<'EOF'
Section "OutputClass"
    Identifier "nvidia"
    MatchDriver "nvidia-drm"
    Driver "nvidia"
    Option "AllowEmptyInitialConfiguration"
    Option "PrimaryGPU" "yes"
    ModulePath "/usr/lib/nvidia/xorg"
    ModulePath "/usr/lib/xorg/modules"
EndSection
EOF
    
    # Add kernel parameters for NVIDIA
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia-drm.modeset=1 /' /mnt/etc/default/grub
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
    
    # Create environment file for Wayland NVIDIA support
    mkdir -p /mnt/etc/environment.d
    echo "WLR_NO_HARDWARE_CURSORS=1" > /mnt/etc/environment.d/10-nvidia-wayland.conf
    
    log "NVIDIA hybrid graphics configured"
}

# Create user
create_user() {
    log "Creating user: $USERNAME..."
    
    arch-chroot /mnt useradd -m -G wheel,audio,video,optical,storage "$USERNAME"
    arch-chroot /mnt bash -c "echo '$USERNAME:$PASSWORD' | chpasswd"
    
    # Configure sudo
    sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers
    
    log "User $USERNAME created with sudo access"
}

# Post-installation tasks
post_install() {
    log "Running post-installation tasks..."
    
    # Set up KDE Wayland session
    arch-chroot /mnt bash -c "mkdir -p /home/$USERNAME/.config"
    
    # Create a script for user to run after first boot
    cat > /mnt/home/$USERNAME/setup-kde.sh <<'EOF'
#!/bin/bash
# KDE Plasma Wayland setup script
# Run this after first login

# Ensure Wayland session is available
if ! grep -q "wayland" /usr/share/xsessions/*.desktop 2>/dev/null; then
    echo "Wayland session should be available. If not, install: plasma-wayland-session"
fi

echo "KDE Plasma Wayland setup complete!"
echo "Select 'Plasma (Wayland)' from the SDDM login screen"
EOF
    chmod +x /mnt/home/$USERNAME/setup-kde.sh
    arch-chroot /mnt chown -R "$USERNAME:$USERNAME" /home/$USERNAME
    
    log "Post-installation tasks completed"
}

# Main installation function
main() {
    echo "=========================================="
    echo "Arch Linux Installation Script"
    echo "System: MSI Laptop (Intel Core Ultra 7 155H)"
    echo "=========================================="
    echo ""
    
    check_root
    verify_uefi
    set_keyboard
    check_internet
    update_clock
    detect_partitions
    format_partitions
    mount_filesystems
    install_base
    generate_fstab
    configure_system
    configure_grub
    configure_nvidia
    create_user
    post_install
    
    echo ""
    echo "=========================================="
    log "Installation completed successfully!"
    echo "=========================================="
    echo ""
    warn "Next steps:"
    echo "  1. Exit chroot: exit"
    echo "  2. Unmount: umount -R /mnt"
    echo "  3. Reboot: reboot"
    echo "  4. Remove USB and boot into Arch Linux"
    echo "  5. Login as: $USERNAME"
    echo "  6. Password: $PASSWORD"
    echo ""
    warn "After first boot:"
    echo "  - Run: ~/setup-kde.sh"
    echo "  - Select 'Plasma (Wayland)' from login screen"
    echo "  - GRUB menu should show both Arch Linux and Windows"
    echo ""
}

# Run main function
main

