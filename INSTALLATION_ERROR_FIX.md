# Installation Error Fix - plasma-wayland-session

## ❌ Error Encountered

```
error: target not found: plasma-wayland-session
==> ERROR: Failed to install packages to new root
```

## ✅ Solution

The package `plasma-wayland-session` doesn't exist as a standalone package. The Wayland session is **included** in the `plasma` package group.

## 🔧 What to Do Now

### Option 1: Re-run Script (Recommended)

The script has been fixed. Download the updated version and run again:

```bash
# Download updated script
curl -O https://raw.githubusercontent.com/michalkay-pixel/arch/main/install-arch.sh
chmod +x install-arch.sh

# Run script again
./install-arch.sh
```

**Note**: Since partitions are already formatted, the script will:
- Skip formatting (partitions already formatted)
- Re-mount partitions
- Continue with package installation

### Option 2: Continue Manually (If You Want to Proceed)

If you want to continue from where it failed:

1. **Mount partitions** (if not already mounted):
```bash
mount /dev/nvme0n1p6 /mnt          # Root
mount /dev/nvme0n1p7 /mnt/home     # Home
mount /dev/nvme0n1p1 /mnt/boot/efi # EFI
```

2. **Install packages manually** (without plasma-wayland-session):
```bash
pacstrap -K /mnt \
    base linux linux-firmware intel-ucode \
    ntfs-3g networkmanager iwd \
    mesa vulkan-intel intel-media-driver libva-intel-driver \
    nvidia nvidia-utils nvidia-settings \
    plasma wayland xorg-xwayland sddm \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack \
    grub efibootmgr os-prober \
    nano vim man-db man-pages texinfo sudo
```

3. **Continue with the rest of the script**:
   - Generate fstab
   - Configure system
   - Install GRUB
   - etc.

## ✅ Verification

After installation, the Wayland session will be available because:
- The `plasma` package group includes Wayland session files
- You'll see "Plasma (Wayland)" option in SDDM login screen

## 📝 What Changed

**Removed from script:**
- `plasma-wayland-session` (invalid package name)

**Kept in script:**
- `plasma` (includes Wayland session)
- `wayland` (Wayland protocol)
- `xorg-xwayland` (X11 compatibility layer)

The Wayland session is automatically available when you install the `plasma` package group.

