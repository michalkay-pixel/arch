# Unmount Troubleshooting Guide

## 🔍 Problem: /mnt is busy or exit didn't work

### Step 1: Check if you're still in chroot

First, verify if you're still in the chroot environment:

```bash
# Check if you're in chroot (look at the prompt)
# If you see: [root@archiso /mnt]#  → You're STILL in chroot
# If you see: [root@archiso /]#     → You're OUT of chroot (good!)

# Or check the hostname
hostname
# If it says "swiftarch" → You're in chroot (STILL mounted)
# If it says "archiso"   → You're out of chroot (can unmount)
```

### Step 2: Exit chroot properly

If you're still in chroot, exit properly:

```bash
# Method 1: Type exit
exit

# Method 2: Press Ctrl+D (same as exit)

# Method 3: If exit doesn't work, try:
exec /usr/bin/bash
exit
```

**Verify you're out:**
- Your prompt should change from `/mnt` to `/`
- Run `ls /mnt` - if you see the mounted partitions, you're OUT
- If you get an error or see root files, you're IN chroot

### Step 3: Find what's keeping /mnt busy

If exit worked but unmount still fails:

```bash
# Find processes using /mnt
lsof /mnt
# or
fuser -v /mnt
# or
lsof +D /mnt
```

**Common culprits:**
- Shell sessions still open in /mnt
- Package manager processes (pacman)
- File managers or text editors
- Mounted swap file

### Step 4: Force unmount if needed

**Option A: Unmount one by one (Recommended)**

```bash
# Unmount in reverse order
swapoff /mnt/swapfile 2>/dev/null  # If swap was enabled
umount /mnt/boot/efi
umount /mnt/home
umount /mnt

# Or use lazy unmount
umount -l /mnt/boot/efi
umount -l /mnt/home
umount -l /mnt
```

**Option B: Force unmount all (if Option A fails)**

```bash
# Lazy unmount (unmounts when not in use)
umount -l /mnt/boot/efi
umount -l /mnt/home
umount -l /mnt

# Or force unmount (unmounts immediately, may cause data loss)
umount -f /mnt/boot/efi
umount -f /mnt/home
umount -f /mnt

# Or unmount all recursively with lazy flag
umount -Rl /mnt
```

**Option C: Check and kill processes (Last resort)**

```bash
# Find what's using /mnt
lsof /mnt | grep -v "^COMMAND" | awk '{print $2}' | sort -u

# Kill processes (replace PID with actual process ID)
# WARNING: Only do this if you're sure!
kill -9 <PID>

# Or kill all processes using /mnt
fuser -km /mnt
umount -R /mnt
```

## ✅ Step-by-Step Solution

### Complete Procedure:

```bash
# 1. Check if in chroot
pwd
# Should NOT show /mnt

# 2. If still in chroot, exit
exit

# 3. Verify you're out
ls /
# Should see: bin boot dev etc home lib lib64 mnt opt proc root run sbin srv sys tmp usr var

# 4. Check what's mounted
mount | grep /mnt

# 5. Disable swap if enabled
swapoff -a

# 6. Unmount in reverse order
umount /mnt/boot/efi
umount /mnt/home
umount /mnt

# 7. If still busy, use lazy unmount
umount -l /mnt/boot/efi
umount -l /mnt/home  
umount -l /mnt

# 8. Verify unmounted
mount | grep /mnt
# Should show nothing

# 9. Now you can reboot
reboot
```

## 🔧 Quick Fix Commands

**If you're still in chroot:**
```bash
exit
# Or Ctrl+D
```

**If unmount is busy:**
```bash
# Disable swap first
swapoff -a

# Then lazy unmount
umount -Rl /mnt
```

**If nothing works:**
```bash
# Check what's using it
lsof /mnt

# Force unmount everything
umount -fR /mnt 2>/dev/null
umount -Rl /mnt
```

## ✅ Success Indicators

You're ready to reboot when:
- ✅ `mount | grep /mnt` shows nothing
- ✅ `ls /mnt` shows empty directory (or just lost+found)
- ✅ No processes using /mnt (`lsof /mnt` shows nothing)

## 🚀 After Successful Unmount

```bash
# Reboot
reboot

# Remove USB during shutdown (as system is rebooting)
# System should boot into GRUB menu
```

## ⚠️ Important Notes

1. **Don't force unmount unless necessary** - It may cause data loss
2. **Always exit chroot first** - Running processes in chroot will keep /mnt busy
3. **Check for swap** - Swap files/partitions need to be disabled first
4. **Lazy unmount is safer** - It unmounts when processes finish

## 🔍 Debugging Commands

```bash
# Check if in chroot
pwd
hostname

# Check what's mounted
mount | grep /mnt
lsblk

# Check processes
ps aux | grep chroot
lsof /mnt
fuser -v /mnt

# Check swap
swapon --show
swapoff -a
```

