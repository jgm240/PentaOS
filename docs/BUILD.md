# PentaOS Build Guide

## Overview

This guide explains how to build and deploy PentaOS on your Raspberry Pi.

## Prerequisites

### System Requirements
- **A real Linux system is required for `customize-rpi-image.sh` / `release-image.sh`** (Ubuntu, Debian, Raspberry Pi OS, etc.). These scripts read partition tables with `sfdisk`, loop-mount the ext4 root partition, and edit the FAT32 boot partition with `mtools` - none of that exists on macOS or Windows, even via Homebrew, because it depends on Linux-specific tooling (`losetup`, `sfdisk`, ext4 mount support). `build-pentaos.sh` (download-only) has no such requirement.
- On macOS/Windows, run the build inside a Linux container instead:
  ```bash
  docker run --rm --privileged -v "$PWD":/work -w /work debian:trixie bash -c "
    apt-get update -qq &&
    apt-get install -y -qq wget xz-utils parted dosfstools kpartx util-linux fdisk mtools e2fsprogs python3 &&
    chmod +x build/*.sh &&
    ./build/build-pentaos.sh &&
    ./build/release-image.sh
  "
  ```
- 8GB free disk space minimum
- Internet connection for downloading OS images
- MicroSD card reader

### Required Tools
```bash
sudo apt-get update
sudo apt-get install -y wget xz-utils parted dosfstools kpartx util-linux fdisk mtools e2fsprogs python3
```

### Optional Tools
- `pv` - for progress indication during flashing

## Building PentaOS

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/pentaos.git
cd pentaos
```

### Step 2: Make Scripts Executable

```bash
chmod +x build/*.sh
```

### Step 3: Download Raspberry Pi OS Base

```bash
./build/build-pentaos.sh
```

This script will:
1. Check system requirements
2. Download latest Raspberry Pi OS
3. Extract the image
4. Create the base image in `images/`

The download takes 5-15 minutes depending on internet speed.

### Step 4: Create Bootable PentaOS Image

**Option A: Quick Image (Customized Base)**

```bash
sudo ./build/customize-rpi-image.sh
```

This customizes the Raspberry Pi OS image with:
- PentaOS branding and wallpaper
- System configuration
- Welcome message
- Pre-configured packages
- Boot splash screen

**Option B: Create Release Image (.img.xz)**

```bash
sudo ./build/release-image.sh
```

This creates a complete release package with:
1. Customized PentaOS image
2. Compressed .img.xz file
3. SHA256 and MD5 checksums
4. Release notes and documentation
5. Installation guide

The customization process requires root privileges and takes 10-30 minutes (longer if mounting/unmounting is slow).

### Step 5: Verify the Image

```bash
# Check image exists
ls -lh images/pentaos-*.img

# Or check release files
ls -lh releases/
```

### Step 4: Verify the Image

```bash
ls -lh images/
# Should show: pentaos-1.0.0-arm64.img
```

## Flashing to SD Card

### Option 1: Using the Flash Script (Recommended)

```bash
# Insert SD card and identify its device (e.g., /dev/sdb)
lsblk

# Flash the image (replace sdX with your device)
sudo ./build/flash-sd-card.sh /dev/sdX
```

### Option 2: Manual Flashing with dd

```bash
# Find your SD card device
lsblk

# Unmount any mounted partitions
sudo umount /dev/sdX*

# Flash the image
sudo dd if=images/pentaos-1.0.0-arm64.img of=/dev/sdX bs=4M status=progress conv=fsync

# Sync to ensure all data is written
sudo sync
```

### Option 3: Using Balena Etcher (GUI)

```bash
# Install Balena Etcher
# https://www.balena.io/etcher/

# Then:
# 1. Open Balena Etcher
# 2. Select: images/pentaos-1.0.0-arm64.img
# 3. Select your SD card
# 4. Click "Flash"
```

## First Boot

### Initial Setup

1. Insert SD card into Raspberry Pi
2. Connect power supply
3. Wait for first boot to complete (2-3 minutes)
4. Connect via SSH or HDMI

### Default Credentials
- **Username:** pi
- **Password:** raspberry

⚠️ **Change the default password immediately!**

```bash
passwd
```

### Desktop Environment Setup

If your Raspberry Pi has internet access during first boot, PentaOS will automatically offer a choice of desktop environments:

#### Automatic First-Boot Setup (Recommended)

When PentaOS detects an internet connection on first boot, it will automatically launch an interactive setup wizard that lets you choose your desktop environment.

**Options:**
1. **GNOME** - Feature-rich, modern desktop (requires 4GB+ RAM)
2. **KDE Plasma** - Customizable, powerful desktop (requires 4GB+ RAM)
3. **Raspberry Pi Desktop (XFCE)** - Lightweight, optimized (requires 1GB+ RAM)
4. **Headless** - Command-line only (minimal resources)

#### Manual Setup

If the automatic setup didn't run, you can manually configure your desktop environment:

```bash
# Run the desktop setup script
sudo /usr/local/bin/pentaos-setup-desktop

# Or from the build directory
sudo build/setup-desktop.sh
```

The script will:
- Check your internet connection
- Show system requirements for each option
- Install your chosen desktop environment
- Configure the display manager
- Clean up package cache

#### Changing Desktop Environments Later

To switch to a different desktop environment later:

```bash
# Re-run the setup script
sudo build/setup-desktop.sh

# Or update specific packages
sudo apt-get install gnome-desktop-environment
sudo apt-get install kde-plasma-desktop
sudo apt-get install raspberrypi-ui-mods
```

### Post-Installation Configuration

```bash
# Run the configuration tool
sudo raspi-config

# In the menu:
# 1. Localization Options → Set timezone and locale
# 2. Advanced Options → Expand Filesystem
# 3. Display Options → Set screen resolution
# 4. Interfacing Options → Enable SSH/VNC if needed
```

## Remote Access

### SSH Access

```bash
# From another computer
ssh pi@<raspberry-pi-ip-address>

# Or if mDNS is configured
ssh pi@raspberrypi.local
```

### VNC Access (Optional)

```bash
# Enable VNC via raspi-config
sudo raspi-config

# Then use a VNC client to connect
# Client: https://www.realvnc.com/en/connect/download/viewer/
```

## Troubleshooting

### Image Download Fails

**Problem:** Wget fails to download OS image

**Solution:**
```bash
# Check internet connection
ping google.com

# Try with a different mirror or retry
./build/build-pentaos.sh

# Or manually download:
cd images
wget https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2026-06-19/2026-06-18-raspios-trixie-arm64-lite.img.xz
cd ..
```

### SD Card Not Detected

**Problem:** Device `/dev/sdX` not found

**Solution:**
```bash
# List all storage devices
lsblk
sudo fdisk -l

# Check system messages
dmesg | tail -20

# Ensure SD card is properly inserted and reader is connected
```

### Flashing Permission Denied

**Problem:** Permission denied when writing to `/dev/sdX`

**Solution:**
```bash
# Use sudo
sudo ./build/flash-sd-card.sh /dev/sdX

# Or add user to disk group (not recommended)
sudo usermod -a -G disk $USER
```

### Raspberry Pi Won't Boot

**Problem:** SD card is inserted but Pi doesn't boot

**Solution:**
1. Check power supply (at least 2A for Pi 3/4)
2. Verify SD card is fully inserted
3. Try different SD card
4. Flash image again (may be corrupted)
5. Check LED lights on Pi

## Building Customizations

### Adding Custom Files

1. Create files in `src/customizations/`
2. Update `build/customize-image.sh`
3. Rebuild with `./build/build-pentaos.sh`

### Modifying Kernel Parameters

Edit `src/config/boot/cmdline.txt` for kernel boot parameters.

### Custom Boot Splash

Add your custom splash screen image to `branding/` and update boot configuration.

## Build Statistics

### Image Size
- Raspberry Pi OS Base: ~2.5GB (uncompressed)
- PentaOS (with customizations): ~2.8GB (uncompressed)
- Compressed (XZ): ~800MB

### Build Time
- Fresh build: 10-15 minutes (varies with internet)
- Incremental: 2-5 minutes

## Clean Build

To rebuild from scratch:

```bash
# Remove downloaded images
rm -rf images/

# Rebuild
./build/build-pentaos.sh
```

## Support

For issues or questions:
- Check GitHub Issues: https://github.com/yourusername/pentaos/issues
- See Raspberry Pi Documentation: https://www.raspberrypi.org/documentation/

---

Last Updated: 2026-09-13
