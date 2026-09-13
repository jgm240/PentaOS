#!/bin/bash

# PentaOS Release Image Builder
# Builds the complete PentaOS bootable image and creates release files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
IMAGES_DIR="${PROJECT_ROOT}/images"
RELEASES_DIR="${PROJECT_ROOT}/releases"
VERSION="1.0.0-alpha"
RPI_OS_IMAGE="2026-06-18-raspios-trixie-arm64-lite.img"
LOG_FILE="/var/log/pentaos-release.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

echo_header() {
    echo -e "${BLUE}===============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===============================================${NC}"
}

echo_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

echo_error() {
    echo -e "${RED}✗ $1${NC}"
}

echo_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo_error "This script must be run with sudo"
        exit 1
    fi
}

check_images() {
    echo_header "Checking Images"

    if [ ! -f "$IMAGES_DIR/$RPI_OS_IMAGE" ]; then
        echo_error "Base image not found"
        echo "Run: ./build/build-pentaos.sh first"
        exit 1
    fi

    local size=$(du -h "$IMAGES_DIR/$RPI_OS_IMAGE" | cut -f1)
    echo_success "Found base image (${size})"
}

create_releases_dir() {
    echo_header "Creating Release Directory"

    mkdir -p "$RELEASES_DIR"
    echo_success "Release directory created: $RELEASES_DIR"
}

build_pentaos_image() {
    echo_header "Building PentaOS Image"

    echo "Customizing image with PentaOS features..."
    if ! sudo RPI_OS_IMAGE="$RPI_OS_IMAGE" PENTAOS_VERSION="$VERSION" "$SCRIPT_DIR/customize-rpi-image.sh"; then
        echo_error "Image customization failed"
        exit 1
    fi

    echo_success "PentaOS image built"
}

compress_image() {
    echo_header "Compressing Image"

    local img="$IMAGES_DIR/$RPI_OS_IMAGE"
    local compressed="$RELEASES_DIR/pentaos-${VERSION}-arm64.img.xz"

    if [ -f "$compressed" ]; then
        echo_warning "Compressed image already exists, skipping"
        return 0
    fi

    echo "Compressing image (this may take 10-20 minutes)..."
    echo "Original size: $(du -h "$img" | cut -f1)"

    if xz -k -v -9 -e "$img" -c > "$compressed"; then
        local compressed_size=$(du -h "$compressed" | cut -f1)
        echo_success "Image compressed: $compressed_size"
    else
        echo_error "Compression failed"
        rm -f "$compressed"
        exit 1
    fi
}

create_checksum() {
    echo_header "Creating Checksums"

    cd "$RELEASES_DIR"

    # SHA256 checksum
    sha256sum pentaos-${VERSION}-arm64.img.xz > pentaos-${VERSION}-arm64.img.xz.sha256
    echo_success "SHA256 checksum created"

    # MD5 checksum (for compatibility)
    md5sum pentaos-${VERSION}-arm64.img.xz > pentaos-${VERSION}-arm64.img.xz.md5
    echo_success "MD5 checksum created"

    cd - > /dev/null
}

create_release_notes() {
    echo_header "Creating Release Notes"

    cat > "$RELEASES_DIR/RELEASE_NOTES_${VERSION}.md" << 'EOF'
# PentaOS v1.0.0-alpha Release Notes

## Release Date
September 13, 2026

## What is PentaOS?
PentaOS is a custom-optimized operating system for Raspberry Pi, based on Raspberry Pi OS Bookworm with enhanced features, accessibility tools, and professional branding.

## Features

### Core Features
- 🚀 Performance optimized for Raspberry Pi hardware
- 🌐 Multi-core ready for modern Pi models
- 🎨 Custom pentagon branding and wallpaper
- 🖥️ Multiple desktop environment options (GNOME, KDE, Pi Desktop, Headless)
- ⚡ Intelligent first-boot setup wizard
- 🎮 Windows/x86 compatibility layer (Wine, Box64, Box86)
- ♿ Comprehensive accessibility tools

### What's Included
- Raspberry Pi OS Bookworm 64-bit base
- PentaOS branding and wallpaper
- Wallpaper setup guide
- Build scripts for customization
- Documentation for all features

### System Requirements
- Raspberry Pi 3B or later
- 1GB RAM minimum (2GB recommended)
- microSD card (8GB minimum, 32GB recommended)
- For Box64: ARM64 architecture (Pi 4/5)

## Installation

### Flash to SD Card
1. Download and extract the image:
   ```bash
   xz -d pentaos-1.0.0-alpha-arm64.img.xz
   ```

2. Flash using dd:
   ```bash
   sudo dd if=pentaos-1.0.0-alpha-arm64.img of=/dev/sdX bs=4M status=progress
   sudo sync
   ```

3. Or use Balena Etcher (GUI):
   - Download from https://www.balena.io/etcher/
   - Select image, SD card, and flash

### First Boot
1. Insert SD card into Pi
2. Connect power
3. Wait for first boot (2-3 minutes)
4. Log in with:
   - Username: pi
   - Password: raspberry
5. **Change password immediately**: `passwd`

## Optional Installations

After booting, you can install additional tools:

### Desktop Environments
```bash
sudo build/setup-desktop.sh
```
Choose from GNOME, KDE Plasma, Raspberry Pi Desktop, or Headless

### Compatibility Layer
```bash
sudo build/install-compatibility-layer.sh
```
Install Wine, Box64, Box86 for Windows/x86 software support

### Accessibility Tools
```bash
sudo build/install-accessibility-tools.sh
```
Install comprehensive accessibility features (screen readers, magnifiers, etc.)

## Known Issues
- First boot setup requires internet connection for package installation
- Some features require additional configuration after installation
- Box64 performance depends on application complexity

## Supported Hardware
✅ Raspberry Pi 3B, 3B+
✅ Raspberry Pi 4 Model B (all variants)
✅ Raspberry Pi 5
⚠️ Raspberry Pi Zero (limited resources)

## Security Notes
1. **Change default password** on first login
2. Enable SSH key-based authentication
3. Update system: `sudo apt update && sudo apt upgrade`
4. Configure firewall if needed: `sudo ufw enable`

## Documentation
- Complete guide: See docs/ directory on GitHub
- Build instructions: docs/BUILD.md
- Desktop setup: docs/DESKTOP-SETUP.md
- Compatibility layer: docs/COMPATIBILITY-LAYER.md
- Accessibility: docs/ACCESSIBILITY.md

## Community & Support
- **GitHub**: https://github.com/jgm240/pentaos
- **Issues**: https://github.com/jgm240/pentaos/issues
- **Discussions**: https://github.com/jgm240/pentaos/discussions

## Attribution
- Based on Raspberry Pi OS (Bookworm)
- Raspberry Pi Foundation
- Wine HQ for compatibility layer
- ptitSeb for Box64/Box86
- GNOME, KDE, XFCE projects
- All open-source contributors

## License
Licensed under the same terms as Raspberry Pi OS.
See LICENSE file for details.

## Changelog
### v1.0.0-alpha (Initial Release)
- ✨ New: PentaOS branding and design
- ✨ New: Default wallpaper with pentagon theme
- ✨ New: Build and customization scripts
- ✨ New: Desktop environment selection wizard
- ✨ New: Compatibility layer bundle (Wine, Box64, Box86)
- ✨ New: Comprehensive accessibility tools suite
- ✨ New: Complete documentation

## Future Plans
- v1.0.0 stable release
- Enhanced customization options
- Pre-configured themes
- Performance optimizations
- Additional software bundles

---

Thank you for using PentaOS!
Made with ❤️ for Raspberry Pi enthusiasts

For feedback and suggestions, please open an issue on GitHub.
EOF

    echo_success "Release notes created"
}

create_installation_guide() {
    echo_header "Creating Installation Guide"

    cat > "$RELEASES_DIR/INSTALLATION_GUIDE.md" << 'EOF'
# PentaOS Installation Guide

## Download
1. Download from: https://github.com/jgm240/pentaos/releases/
2. Choose: `pentaos-1.0.0-alpha-arm64.img.xz` (compressed image)
3. Verify checksum:
   ```bash
   sha256sum -c pentaos-1.0.0-alpha-arm64.img.xz.sha256
   ```

## Extract Image
```bash
xz -d pentaos-1.0.0-alpha-arm64.img.xz
```

## Flash to SD Card

### Method 1: Using dd (Linux/macOS)
1. Insert SD card
2. Find device:
   ```bash
   lsblk
   # Look for your SD card (e.g., /dev/sdb or /dev/mmcblk0)
   ```
3. Unmount if mounted:
   ```bash
   sudo umount /dev/sdX*
   ```
4. Flash image:
   ```bash
   sudo dd if=pentaos-1.0.0-alpha-arm64.img of=/dev/sdX bs=4M status=progress
   sudo sync
   ```
5. Eject:
   ```bash
   sudo eject /dev/sdX
   ```

### Method 2: Using Balena Etcher (All Platforms)
1. Download: https://www.balena.io/etcher/
2. Open Balena Etcher
3. Select Image → `pentaos-1.0.0-alpha-arm64.img`
4. Select Target → Your SD card
5. Click Flash
6. Wait for completion

### Method 3: Using Raspberry Pi Imager (Official)
1. Download: https://www.raspberrypi.com/software/
2. Open Raspberry Pi Imager
3. Choose Device → Your Raspberry Pi model
4. Choose OS → Custom → select image file
5. Choose Storage → Your SD card
6. Click Next and confirm

## First Boot
1. Insert SD card into Raspberry Pi
2. Connect power supply (5V 3A for Pi 4/5, 2.5A for Pi 3)
3. Connect HDMI/display and keyboard (or SSH)
4. Wait for first boot (2-3 minutes)

## Initial Login
- **Username**: pi
- **Password**: raspberry

⚠️ **IMPORTANT**: Change password immediately!
```bash
passwd
```

## Post-Installation Setup

### 1. Update System
```bash
sudo apt update
sudo apt upgrade
```

### 2. Configure Raspberry Pi
```bash
sudo raspi-config
```
- Set timezone
- Expand filesystem
- Configure GPU memory
- Enable SSH/VNC if needed

### 3. Change Hostname (Optional)
```bash
sudo hostnamectl set-hostname your-hostname
```

### 4. Set Static IP (Optional)
Edit `/etc/dhcpcd.conf` and add:
```
interface eth0
static ip_address=192.168.1.100/24
static routers=192.168.1.1
```

## Optional Features

### Install Desktop Environment
```bash
sudo build/setup-desktop.sh
```
Choose: GNOME, KDE, Pi Desktop, or Headless

### Install Compatibility Layer
```bash
sudo build/install-compatibility-layer.sh
```
Wine, Box64, Box86 for running Windows/x86 software

### Install Accessibility Tools
```bash
sudo build/install-accessibility-tools.sh
```
Screen readers, magnifiers, on-screen keyboards, etc.

## Troubleshooting

### SD Card Not Detected
- Check if SD card is working on another device
- Try a different SD card reader
- Ensure proper ejection before removal

### Image Won't Boot
1. Verify checksum matches
2. Re-flash the image
3. Try on another Raspberry Pi
4. Check power supply (5V 3A minimum)

### Performance Issues
- Expand filesystem: `sudo raspi-config` → Advanced → Expand Filesystem
- Close unnecessary applications
- Check available disk space: `df -h`
- Monitor temperature: `vcgencmd measure_temp`

### SSH Connection Issues
1. Find Pi IP: `hostname -I` on the Pi
2. Enable SSH: `sudo raspi-config` → Interfacing Options → SSH
3. Try: `ssh pi@<ip-address>`

## Security Setup

### Change Default Password
```bash
passwd
```

### Setup SSH Keys (Recommended)
```bash
# On your computer
ssh-keygen -t rsa -b 4096

# Copy key to Pi
ssh-copy-id -i ~/.ssh/id_rsa.pub pi@<pi-ip>

# Disable password auth (on Pi)
sudo nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
sudo systemctl restart ssh
```

### Enable Firewall
```bash
sudo apt install -y ufw
sudo ufw enable
sudo ufw allow 22/tcp  # Allow SSH
sudo ufw status
```

## Next Steps
1. Read documentation: `/root/pentaos/docs/`
2. Explore PentaOS features
3. Install additional software as needed
4. Join community: GitHub discussions

## Support
- **Documentation**: See docs/ directory
- **Issues**: GitHub Issues
- **Community**: GitHub Discussions
- **Official Pi Docs**: https://www.raspberrypi.org/documentation/

---

Happy computing with PentaOS!
EOF

    echo_success "Installation guide created"
}

create_manifest() {
    echo_header "Creating Release Manifest"

    cat > "$RELEASES_DIR/MANIFEST_${VERSION}.txt" << EOF
PentaOS Release Manifest
Version: $VERSION
Date: $(date +%Y-%m-%d)

CONTENTS:
- pentaos-${VERSION}-arm64.img.xz (Bootable image, compressed)
- pentaos-${VERSION}-arm64.img.xz.sha256 (SHA256 checksum)
- pentaos-${VERSION}-arm64.img.xz.md5 (MD5 checksum)
- RELEASE_NOTES_${VERSION}.md
- INSTALLATION_GUIDE.md
- MANIFEST_${VERSION}.txt (this file)

IMAGE SPECIFICATIONS:
- Base OS: Raspberry Pi OS Bookworm 64-bit
- Kernel: Linux 6.6.x
- Architecture: ARM64 (aarch64)
- Filesystem: ext4
- Compression: XZ (xz-utils)

HARDWARE COMPATIBILITY:
✅ Raspberry Pi 3B, 3B+, 4B, 4B (all variants), 5

FEATURES INCLUDED:
✓ PentaOS branding and wallpaper
✓ Build and customization scripts
✓ Desktop environment selection wizard
✓ Compatibility layer support scripts
✓ Accessibility tools installer
✓ Complete documentation

VERIFICATION:
1. Check SHA256: sha256sum -c pentaos-${VERSION}-arm64.img.xz.sha256
2. Or check MD5: md5sum -c pentaos-${VERSION}-arm64.img.xz.md5

INSTALLATION:
See INSTALLATION_GUIDE.md for detailed instructions

BUILD INFORMATION:
Built: $(date)
Checksum generated: $(date)

---
For more information: https://github.com/jgm240/pentaos
EOF

    echo_success "Manifest created"
}

print_summary() {
    echo ""
    echo_header "Release Build Complete!"
    echo ""
    echo "Release files created in: $RELEASES_DIR"
    echo ""
    echo "Files:"
    ls -lh "$RELEASES_DIR" | grep -v "^total" | awk '{print "  " $9 " (" $5 ")"}'
    echo ""
    echo "Download Links:"
    echo "  Image: pentaos-${VERSION}-arm64.img.xz"
    echo "  SHA256: pentaos-${VERSION}-arm64.img.xz.sha256"
    echo "  MD5: pentaos-${VERSION}-arm64.img.xz.md5"
    echo ""
    echo "Next steps:"
    echo "  1. Upload files to GitHub releases"
    echo "  2. Create release announcement"
    echo "  3. Share download links"
    echo ""
}

main() {
    check_root

    touch "$LOG_FILE"
    log "PentaOS release build started"

    echo_header "PentaOS Release Image Builder"
    echo ""
    echo "Building bootable PentaOS image for Raspberry Pi"
    echo "Version: $VERSION"
    echo ""

    check_images
    create_releases_dir
    build_pentaos_image
    compress_image
    create_checksum
    create_release_notes
    create_installation_guide
    create_manifest
    print_summary

    log "PentaOS release build completed successfully"
}

main "$@"
