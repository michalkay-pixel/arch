# Arch Linux Installation Script for MSI Laptop

Automated installation script for Arch Linux on MSI laptop with Intel Core Ultra 7 155H, Intel Arc Graphics, and NVIDIA RTX 3050.

## System Specifications

- **CPU**: Intel Core Ultra 7 155H (Meteor Lake)
- **RAM**: 32GB DDR5
- **GPU**: Intel Arc Graphics + NVIDIA RTX 3050 6GB (Hybrid)
- **Storage**: Samsung NVMe SSD (953GB)
- **Network**: Intel Ethernet + Killer Wi-Fi 7 BE200D2W
- **Audio**: Realtek HD Audio

## Pre-Installation Checklist

### 1. Partition Layout

Ensure your disk has the following partitions ready:

- **EFI**: 300MB (existing Windows EFI partition - will be shared)
- **Root**: 100GB (will be formatted to ext4)
- **Home**: 150GB (will be formatted to ext4)
- **Shared**: 50GB (will be formatted to NTFS)

**Current Status**: ✅ Your partition layout is correct and ready!

### 2. Installation Media

1. Download Arch Linux ISO from [archlinux.org/download](https://archlinux.org/download/)
2. Create bootable USB using:
   - **Rufus** (Windows) - recommended
   - **dd** (Linux/Mac)
   - **Ventoy** (multi-ISO support)

### 3. Boot Settings

- Boot from USB
- Ensure **UEFI mode** is enabled (not Legacy/CSM)
- **Secure Boot** must be disabled (Arch Linux doesn't support it yet)

## Installation Steps

### 1. Boot Arch Linux Live Environment

1. Boot from USB
2. Select "Arch Linux install medium" from boot menu
3. You'll be logged in as root with a Zsh shell

### 2. Download and Run Script

#### Option A: From GitHub (Recommended)

```bash
# Download script
curl -O https://raw.githubusercontent.com/michalkay-pixel/arch/main/install-arch.sh

# Or with wget
wget https://raw.githubusercontent.com/michalkay-pixel/arch/main/install-arch.sh

# Make executable
chmod +x install-arch.sh

# Run script
./install-arch.sh
```

#### Option B: From USB

If you copied the script to your USB drive:

```bash
# Mount USB (if not already mounted)
mkdir -p /mnt/usb
mount /dev/sdX1 /mnt/usb  # Replace sdX1 with your USB partition

# Copy and run
cp /mnt/usb/install-arch.sh .
chmod +x install-arch.sh
./install-arch.sh
```

### 3. Follow Script Prompts

The script will:

1. ✅ Verify UEFI boot mode
2. ✅ Set UK keyboard layout
3. ✅ Check internet connection
4. ✅ Show partition layout
5. ⚠️ **Ask you to confirm partition selection** (IMPORTANT!)
6. ⚠️ **Ask for confirmation before formatting** (safety check)
7. ✅ Format partitions (root/home to ext4, shared to NTFS)
8. ✅ Install base system and all packages
9. ✅ Configure system (timezone, locale, hostname)
10. ✅ Install and configure GRUB (with Windows detection)
11. ✅ Configure NVIDIA hybrid graphics
12. ✅ Create user account

### 4. Partition Selection

When prompted, enter your partition paths:

- **EFI**: `/dev/nvme0n1p1` (300MB, usually first partition)
- **Root**: `/dev/nvme0n1p6` (100GB partition)
- **Home**: `/dev/nvme0n1p7` (150GB partition)
- **Shared**: `/dev/nvme0n1pX` (50GB partition - check with `lsblk`)

**Safety**: The script will warn you before formatting anything!

### 5. After Installation

```bash
# Exit chroot
exit

# Unmount partitions
umount -R /mnt

# Reboot
reboot
```

**Remember**: Remove USB before booting!

## Post-Installation

### First Boot

1. Boot into Arch Linux (GRUB menu should show both Arch and Windows)
2. Login as: `swiftarch`
3. Password: `1706`

### KDE Plasma Wayland Setup

The Wayland session is automatically included when you install the `plasma` package group.

1. At SDDM login screen, click on session type
2. Select **"Plasma (Wayland)"**
3. Login

Or run the setup script:

```bash
~/setup-kde.sh
```

**Note**: If you don't see "Plasma (Wayland)" option, it means the `plasma` package wasn't fully installed. Re-run the installation script.

### Network Configuration

NetworkManager should start automatically. To connect to Wi-Fi:

```bash
# Using nmtui (text UI)
nmtui

# Or using nmcli
nmcli device wifi list
nmcli device wifi connect "SSID" password "password"
```

### NVIDIA Graphics

The script configures hybrid graphics. To switch between GPUs:

```bash
# Check NVIDIA status
nvidia-smi

# For Wayland, NVIDIA support is enabled via environment variables
# (already configured in the script)
```

### Shared Partition

The 50GB NTFS shared partition will be mounted at `/mnt/shared` and accessible from both Windows and Linux.

## Configuration Details

### System Settings

- **Hostname**: `swiftarch`
- **Username**: `swiftarch`
- **Password**: `1706` (for both root and user)
- **Timezone**: `Europe/London`
- **Keyboard**: UK layout
- **Locale**: `en_GB.UTF-8`

### Installed Packages

**Base System:**
- base, linux, linux-firmware, intel-ucode

**File Systems:**
- btrfs-progs, ntfs-3g

**Networking:**
- networkmanager, iwd

**Graphics:**
- mesa, vulkan-intel, intel-media-driver, libva-intel-driver
- nvidia, nvidia-utils, nvidia-settings

**Desktop:**
- plasma (includes Wayland session), wayland, xorg-xwayland, sddm

**Audio:**
- pipewire, pipewire-pulse, pipewire-alsa, pipewire-jack

**Bootloader:**
- grub, efibootmgr, os-prober

## Troubleshooting

### Script Fails at Internet Check

```bash
# Connect manually first
iwctl
[iwctl]# device list
[iwctl]# station wlan0 connect "SSID"
[iwctl]# exit

# Then run script again
```

### GRUB Doesn't Show Windows

```bash
# After installation, chroot and regenerate GRUB
arch-chroot /mnt
grub-mkconfig -o /boot/grub/grub.cfg
```

### NVIDIA Not Working

```bash
# Check if NVIDIA modules are loaded
lsmod | grep nvidia

# Check NVIDIA driver
nvidia-smi

# Rebuild initramfs if needed
sudo mkinitcpio -P
```

### Wi-Fi Not Working

```bash
# Enable and start NetworkManager
sudo systemctl enable --now NetworkManager

# Or use iwd directly
iwctl
```

### Package Installation Error: "plasma-wayland-session not found"

**Error**: `error: target not found: plasma-wayland-session`

**Solution**: This package doesn't exist as a standalone package. The Wayland session is included in the `plasma` package group.

1. Download the updated script (already fixed):
   ```bash
   curl -O https://raw.githubusercontent.com/michalkay-pixel/arch/main/install-arch.sh
   chmod +x install-arch.sh
   ./install-arch.sh
   ```

2. If partitions are already formatted, the script will re-mount and continue.

**Note**: The Wayland session is automatically available when `plasma` is installed. You'll see "Plasma (Wayland)" in the SDDM login screen.

### Can't Boot After Installation

1. Boot from USB again
2. Mount partitions:
   ```bash
   mount /dev/nvme0n1p6 /mnt
   mount /dev/nvme0n1p7 /mnt/home
   mount /dev/nvme0n1p1 /mnt/boot/efi
   arch-chroot /mnt
   ```
3. Check and fix GRUB:
   ```bash
   grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
   grub-mkconfig -o /boot/grub/grub.cfg
   ```

## Safety Features

- ✅ Verifies UEFI boot mode
- ✅ Checks internet connection
- ✅ Shows partition layout before formatting
- ✅ Requires explicit confirmation before formatting
- ✅ Warns about unusual partition sizes
- ✅ Does NOT format EFI partition (preserves Windows bootloader)
- ✅ Does NOT touch Windows partitions

## References

- [Arch Linux Installation Guide](https://wiki.archlinux.org/title/Installation_guide)
- [GRUB Documentation](https://wiki.archlinux.org/title/GRUB)
- [NVIDIA Hybrid Graphics](https://wiki.archlinux.org/title/NVIDIA#Hybrid_configurations)
- [KDE Plasma Wayland](https://wiki.archlinux.org/title/KDE#Wayland)

## License

This script is provided as-is. Use at your own risk. Always backup important data before installation.

## Support

For issues:
1. Check the troubleshooting section
2. Review Arch Linux Wiki
3. Check system logs: `journalctl -b`

---

**Note**: This script is tailored for the specific MSI laptop configuration. Modify variables at the top of the script for different systems.

