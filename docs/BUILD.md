# PentaOS Build Guide

## Overview

This guide explains how to build and deploy PentaOS on your Raspberry Pi.

## Prerequisites

### System Requirements
- Linux system (Ubuntu, Debian, Raspberry Pi OS, etc.)
- 8GB free disk space minimum
- Internet connection for downloading OS images
- MicroSD card reader

### Required Tools
```bash
sudo apt-get update
sudo apt-get install -y wget xz-utils
```

### Optional Tools
- `pv` - for progress indication during flashing
- `fdisk` or `parted` - for partition management

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

### Step 3: Build the Image

```bash
./build/build-pentaos.sh
```

This script will:
1. Check system requirements
2. Download latest Raspberry Pi OS
3. Extract the image
4. Apply PentaOS customizations
5. Create the final `pentaos-1.0.0-arm64.img`

The build process takes 5-15 minutes depending on internet speed.

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
wget https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2024-10-04/2024-10-04-raspios-bookworm-arm64.img.xz
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
