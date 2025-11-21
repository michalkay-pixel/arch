# Quick Start Guide - Arch Linux Installation

## 🚀 Pre-Flight Checklist

- [ ] USB created with Arch Linux ISO (via Rufus)
- [ ] Secure Boot **DISABLED** in BIOS
- [ ] UEFI mode enabled
- [ ] Internet connection ready (Ethernet cable or Wi-Fi credentials)

## 📥 Download & Run

```bash
# 1. Boot from USB, select "Arch Linux install medium"

# 2. Connect to internet (if Wi-Fi):
iwctl
[iwctl]# station wlan0 connect "YOUR_WIFI"
[iwctl]# exit

# 3. Download script
curl -O https://raw.githubusercontent.com/michalkay-pixel/arch/main/install-arch.sh
chmod +x install-arch.sh

# 4. Run script
./install-arch.sh
```

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

```bash
exit              # Exit chroot
umount -R /mnt    # Unmount
reboot            # Reboot
```

**Remove USB during shutdown!**

## 🔑 First Boot

- **Username**: `swiftarch`
- **Password**: `1706`
- **Session**: Select "Plasma (Wayland)" at login

## 📚 Full Documentation

See `INSTALLATION_REVIEW.md` for complete details and troubleshooting.

