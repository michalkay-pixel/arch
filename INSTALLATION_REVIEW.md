# Final Installation Script Review & Manual Steps Guide

## ✅ Script Review - All Systems Go!

The script has been thoroughly reviewed and is ready for installation. All components align with the latest Arch Linux installation guide.

## 📋 Your Partition Layout (Confirmed)

Based on your disk management screenshot:

**Disk 0 (NVMe SSD - 953.74 GB):**
- **Partition 1**: 300 MB - EFI System Partition (FAT32) → **Use for EFI**
- **Partition (C:)**: 620.76 GB - Windows (NTFS) → **DO NOT TOUCH**
- **Partition 6**: 100.00 GB - Primary Partition (100% free) → **Use for ROOT**
- **Partition 7**: 150.00 GB - Primary Partition (100% free) → **Use for HOME**
- **Partition (D:)**: 50.00 GB - NTFS (100% free) → **Use for SHARED**
- **Partition 4**: 900 MB - Recovery → **DO NOT TOUCH**
- **Partition 5**: 31.02 GB - Recovery → **DO NOT TOUCH**

## 🎯 Expected Partition Inputs

When the script prompts you, enter:

```
EFI partition:   /dev/nvme0n1p1
ROOT partition:  /dev/nvme0n1p6
HOME partition:  /dev/nvme0n1p7
SHARED partition: /dev/nvme0n1pX  (Check with lsblk - check which partition is 50GB)
```

**⚠️ IMPORTANT**: Run `lsblk -f` first to confirm the exact partition numbers, as they may differ slightly.

## 🔧 Manual Steps Required

### Before Running Script

1. **Boot from USB** (Arch Linux ISO created with Rufus)
   - Press boot menu key (usually F12, F8, or Del during boot)
   - Select USB drive
   - Ensure UEFI mode (not Legacy/CSM)
   - Secure Boot must be **DISABLED**

2. **Connect to Internet**
   ```bash
   # If using Ethernet - just plug in cable
   
   # If using Wi-Fi:
   iwctl
   [iwctl]# device list
   [iwctl]# station wlan0 scan
   [iwctl]# station wlan0 get-networks
   [iwctl]# station wlan0 connect "YOUR_WIFI_SSID"
   [iwctl]# password: YOUR_PASSWORD
   [iwctl]# exit
   
   # Verify connection
   ping -c 3 archlinux.org
   ```

3. **Download Script**
   ```bash
   curl -O https://raw.githubusercontent.com/michalkay-pixel/arch/main/install-arch.sh
   chmod +x install-arch.sh
   ```

### During Script Execution

1. **Partition Selection** (Script will prompt)
   - The script will show `lsblk -f` output
   - **Carefully identify** your partitions
   - Enter the exact partition paths when prompted
   - **Double-check** you're NOT selecting Windows (C:) or recovery partitions

2. **Confirmation Prompts**
   - Script will ask for confirmation before formatting
   - Type `yes` exactly (not `y` or `Y`)
   - Review the partition list carefully

### After Script Completes

1. **Exit and Unmount** (Script will remind you)
   ```bash
   exit                    # Exit chroot
   umount -R /mnt         # Unmount all partitions
   ```

2. **Reboot**
   ```bash
   reboot
   ```
   - **Remove USB** as the system shuts down (before it starts booting again)
   - System should boot into GRUB menu showing both Arch Linux and Windows

## ⚠️ Potential Issues & Solutions

### Issue 1: Package Installation Error - "plasma-wayland-session not found"

**Problem**: Script fails with `error: target not found: plasma-wayland-session`

**Solution**: This package doesn't exist. The Wayland session is included in the `plasma` package group.
```bash
# Download the updated script (already fixed):
curl -O https://raw.githubusercontent.com/michalkay-pixel/arch/main/install-arch.sh
chmod +x install-arch.sh
./install-arch.sh

# If partitions are already formatted, script will re-mount and continue
```

**Note**: The script has been fixed. The Wayland session is automatically available when `plasma` is installed.

### Issue 2: NTFS Formatting May Fail

**Problem**: `mkfs.ntfs` might not be available in live environment.

**Solution**: The script has a fallback, but if it fails:
```bash
# After script completes, if shared partition wasn't formatted:
# The partition is already NTFS (D: drive), so it should work as-is
# Or manually format after installation:
sudo mkfs.ntfs -F /dev/nvme0n1pX  # Replace X with your partition number
```

### Issue 3: GRUB Doesn't Show Windows

**Problem**: os-prober might not detect Windows immediately.

**Solution**: After first boot, regenerate GRUB:
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Issue 4: Wi-Fi Not Working After Boot

**Problem**: NetworkManager might not start automatically.

**Solution**:
```bash
sudo systemctl enable --now NetworkManager
nmtui  # Or use GUI to connect
```

### Issue 5: NVIDIA Graphics Issues

**Problem**: Hybrid graphics might need additional configuration.

**Solution**: The script configures PRIME, but if issues occur:
```bash
# Check NVIDIA status
nvidia-smi

# If not working, rebuild initramfs
sudo mkinitcpio -P

# For Wayland, ensure environment variable is set
echo "WLR_NO_HARDWARE_CURSORS=1" | sudo tee -a /etc/environment.d/10-nvidia-wayland.conf
```

### Issue 6: Shared Partition Not Mounting

**Problem**: NTFS partition might not auto-mount.

**Solution**: Check fstab and mount manually if needed:
```bash
# Check fstab
cat /etc/fstab

# Mount manually if needed
sudo mount /dev/nvme0n1pX /mnt/shared  # Replace X with partition number

# Fix permissions if needed
sudo chown swiftarch:swiftarch /mnt/shared
```

## ✅ Script Safety Features Verified

- ✅ UEFI boot mode verification
- ✅ Internet connection check
- ✅ Partition existence validation
- ✅ Partition size warnings
- ✅ Explicit confirmation required before formatting
- ✅ EFI partition is mounted only (not formatted)
- ✅ Windows partitions are not touched (user must select correctly)

## 📝 Post-Installation Checklist

After first successful boot:

- [ ] GRUB menu shows both Arch Linux and Windows
- [ ] Can boot into Arch Linux
- [ ] Can boot into Windows (verify it still works!)
- [ ] Network connection works (Wi-Fi/Ethernet)
- [ ] KDE Plasma Wayland session available
- [ ] NVIDIA graphics detected (`nvidia-smi` works)
- [ ] Shared partition accessible at `/mnt/shared`
- [ ] User can login as `swiftarch` with password `1706`
- [ ] Sudo access works

## 🔍 Verification Commands

After installation, verify everything:

```bash
# Check partitions
lsblk -f

# Check GRUB entries
sudo cat /boot/grub/grub.cfg | grep -i windows

# Check NVIDIA
nvidia-smi

# Check network
ip addr
nmcli device status

# Check mounted filesystems
df -h
mount | grep shared

# Check system info
hostname
whoami
locale
```

## 🚨 Critical Reminders

1. **Backup Important Data**: Even though script has safety checks, always backup important data before installation.

2. **Partition Selection**: The script cannot automatically detect which partitions are Windows - **YOU must verify** when entering partition paths.

3. **EFI Partition**: The script will **NOT format** the EFI partition, but ensure you select the correct 300MB partition.

4. **Windows Boot**: After installation, test that Windows still boots correctly before proceeding with Arch Linux setup.

5. **USB Removal**: Remove USB **during shutdown**, not before running `reboot` command.

## 📚 Additional Resources

- [Arch Linux Installation Guide](https://wiki.archlinux.org/title/Installation_guide)
- [GRUB Troubleshooting](https://wiki.archlinux.org/title/GRUB#Troubleshooting)
- [NVIDIA Hybrid Graphics](https://wiki.archlinux.org/title/NVIDIA#Hybrid_configurations)
- [KDE Plasma Wayland](https://wiki.archlinux.org/title/KDE#Wayland)

---

## ✅ Final Checklist Before Running Script

- [ ] USB created with Arch Linux ISO (Rufus)
- [ ] Secure Boot disabled in BIOS
- [ ] UEFI mode enabled
- [ ] Internet connection available (test with `ping archlinux.org`)
- [ ] Partition layout confirmed (run `lsblk -f` to verify)
- [ ] Important data backed up
- [ ] Script downloaded from GitHub
- [ ] Ready to enter partition paths when prompted

**You're all set! The script is ready to run.** 🚀

