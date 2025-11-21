# Quick Start Guide - Arch Linux Installation

## 🚀 Pre-Flight Checklist

- [ ] USB created with Arch Linux ISO (via Rufus)
- [ ] Secure Boot **DISABLED** in BIOS
- [ ] UEFI mode enabled
- [ ] Internet connection ready (Ethernet cable or Wi-Fi credentials)

## 📥 Download & Run

```bash
# 1. Boot from USB, select "Arch Linux install medium"
#    You'll be logged in as root automatically (prompt: root@archiso ~ #)

# 2. Connect to internet (if Wi-Fi):
iwctl
[iwctl]# station wlan0 connect "YOUR_WIFI"
[iwctl]# exit

# 3. Download script
curl -O https://raw.githubusercontent.com/michalkay-pixel/arch/main/install-arch.sh
chmod +x install-arch.sh

# 4. Run script (as root - you already are!)
./install-arch.sh
```

**Note**: You're already logged in as `root` in the live environment. The script will verify this automatically.

## 🎯 Partition Inputs (When Prompted)

Based on your disk layout:

```
EFI:    /dev/nvme0n1p1    (300MB - existing Windows EFI)
ROOT:   /dev/nvme0n1p6    (100GB - will be formatted to ext4)
HOME:   /dev/nvme0n1p7    (150GB - will be formatted to ext4)
SHARED: /dev/nvme0n1pX    (50GB - check with lsblk first!)
```

**⚠️ Verify with `lsblk -f` before entering!**

## ✅ After Script Completes

**Important**: When the script finishes, you're still in the **live environment** (root@archiso). This is correct!

The script uses `arch-chroot` internally to run commands in the new system, but your shell stays in the live environment.

```bash
# You're already in root@archiso (live environment)
# No need to exit chroot - you were never chrooted!

# Just unmount and reboot:
swapoff -a              # Disable swap first
umount /mnt/boot/efi    # Unmount EFI
umount /mnt/home        # Unmount home
umount /mnt             # Unmount root

# If unmount fails with "busy", use lazy unmount:
umount -Rl /mnt

# Verify unmounted
mount | grep /mnt       # Should show nothing

# Reboot
reboot
```

**Remove USB during shutdown!**

## 🔑 First Boot

- **Username**: `swiftarch`
- **Password**: `1706`
- **Session**: Select "Plasma (Wayland)" at login

## ⚠️ Common Error Fix

If you get `error: target not found: plasma-wayland-session`:

```bash
# Download the updated script (already fixed)
curl -O https://raw.githubusercontent.com/michalkay-pixel/arch/main/install-arch.sh
chmod +x install-arch.sh
./install-arch.sh
```

The script has been fixed - Wayland session is included in the `plasma` package.

## 📚 Full Documentation

See `INSTALLATION_REVIEW.md` for complete details and troubleshooting.

