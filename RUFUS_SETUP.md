# Rufus Setup Guide for Arch Linux USB

## ✅ Correct Settings for UEFI Systems

Based on your system (UEFI boot mode required), use these settings:

### 1. Device Selection
- **Device**: Select your USB drive (128 GB in your case)
- ⚠️ **WARNING**: All data on the USB will be erased!

### 2. Boot Selection
- **Boot selection**: Click "SELECT" and choose `archlinux-2025.11.01-x86_64.iso`
- ✅ ISO should show with a checkmark when selected

### 3. Partition Scheme ⚠️ IMPORTANT
- **Partition scheme**: **GPT** (NOT MBR)
- **Target system**: **UEFI (non CSM)** (NOT "BIOS or UEFI")
- 
**Why**: Your system uses UEFI, and GPT is required for proper UEFI boot. MBR is for legacy BIOS systems.

### 4. Format Options
- **Volume label**: `ARCH_202511` (or any name you prefer)
- **File system**: **FAT32** (NOT NTFS)
- **Cluster size**: `4096 bytes (Default)` is fine

**Why**: UEFI requires FAT32 for the EFI system partition. NTFS won't work for UEFI boot.

### 5. Advanced Options (Optional)
- **Show advanced drive properties**: Usually leave default
- **Show advanced format options**: Usually leave default
- **Persistent partition**: Leave at `0 (No persistence)` - not needed for installation

## 📋 Step-by-Step Instructions

1. **Open Rufus**
   - Run Rufus as Administrator (right-click → Run as administrator)

2. **Select USB Drive**
   - Under "Device", select your USB drive
   - ⚠️ Double-check you selected the correct drive!

3. **Select ISO**
   - Click "SELECT" button
   - Navigate to your downloaded `archlinux-2025.11.01-x86_64.iso`
   - Click "Open"

4. **Change Partition Scheme** ⚠️ CRITICAL
   - Click the dropdown next to "Partition scheme"
   - Select **"GPT"**
   - The "Target system" should automatically change to **"UEFI (non CSM)"**
   - If it doesn't, manually select "UEFI (non CSM)"

5. **Change File System** ⚠️ CRITICAL
   - Click the dropdown next to "File system"
   - Select **"FAT32"** (NOT NTFS)

6. **Set Volume Label** (Optional)
   - Enter: `ARCH_202511` or any name you prefer

7. **Start the Process**
   - Review all settings one more time
   - Click **"START"** button
   - ⚠️ You'll get a warning about data loss - click "OK" to proceed
   - Wait for the process to complete (usually 5-10 minutes)

8. **Verify**
   - Status should show "READY" when complete
   - You can safely close Rufus

## ⚠️ Common Mistakes to Avoid

### ❌ Wrong Settings (What you currently have):
- Partition scheme: **MBR** ❌
- Target system: **BIOS or UEFI** ❌
- File system: **NTFS** ❌

### ✅ Correct Settings (What you need):
- Partition scheme: **GPT** ✅
- Target system: **UEFI (non CSM)** ✅
- File system: **FAT32** ✅

## 🔍 Why These Settings Matter

1. **GPT vs MBR**:
   - GPT is required for UEFI boot on modern systems
   - MBR is for legacy BIOS systems (your system uses UEFI)

2. **FAT32 vs NTFS**:
   - UEFI firmware can only read FAT32 filesystems
   - NTFS won't be recognized by UEFI bootloader
   - FAT32 has a 4GB file size limit, but ISO files are usually smaller

3. **UEFI (non CSM)**:
   - Ensures pure UEFI boot (no legacy compatibility mode)
   - Matches your system's boot mode requirement

## ✅ Verification After Creation

After Rufus completes:

1. **Check USB Contents** (Optional):
   - Open File Explorer
   - You should see the USB drive with Arch Linux files
   - Should see folders like `EFI`, `arch`, etc.

2. **Test Boot** (Recommended before installation):
   - Restart your computer
   - Press boot menu key (F12, F8, or Del - check your laptop manual)
   - Select USB drive from boot menu
   - You should see Arch Linux boot menu
   - If it boots successfully, you're ready!

## 🚀 Next Steps

Once USB is created correctly:

1. Boot from USB
2. Select "Arch Linux install medium" from boot menu
3. Follow the installation script instructions

## 📝 Quick Reference

**Rufus Settings Summary:**
```
Device: [Your USB Drive]
Boot selection: archlinux-2025.11.01-x86_64.iso
Partition scheme: GPT
Target system: UEFI (non CSM)
Volume label: ARCH_202511
File system: FAT32
Cluster size: 4096 bytes (Default)
```

---

**Note**: If you've already created the USB with wrong settings (MBR/NTFS), simply run Rufus again with the correct settings. The USB will be reformatted with the correct configuration.

