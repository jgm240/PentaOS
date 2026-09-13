#!/bin/bash

# PentaOS Image Customization Script
# Mounts and customizes a Raspberry Pi OS image with PentaOS branding and tools

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
IMAGES_DIR="${PROJECT_ROOT}/images"
MOUNT_DIR="/mnt/pentaos-build"
LOG_FILE="/var/log/pentaos-customize.log"

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

check_image() {
    if [ ! -f "$IMAGES_DIR/2024-10-04-raspios-bookworm-arm64.img" ]; then
        echo_error "Raspberry Pi OS image not found"
        echo "Run: ./build/build-pentaos.sh first"
        exit 1
    fi
    echo_success "Base image found"
}

cleanup_mounts() {
    echo_header "Cleaning Up Mounts"

    # Unmount if mounted
    if mountpoint -q "$MOUNT_DIR/boot"; then
        umount "$MOUNT_DIR/boot" || true
    fi
    if mountpoint -q "$MOUNT_DIR"; then
        umount "$MOUNT_DIR" || true
    fi

    # Remove mount directory
    [ -d "$MOUNT_DIR" ] && rmdir "$MOUNT_DIR" || true

    echo_success "Mounts cleaned"
}

setup_mounts() {
    echo_header "Setting Up Image Mounts"

    local image="$IMAGES_DIR/2024-10-04-raspios-bookworm-arm64.img"

    # Create mount directory
    mkdir -p "$MOUNT_DIR"

    # Find partition offsets using fdisk
    local partition_info=$(fdisk -l "$image" | grep "^$image")

    # Extract partition offsets (simplified - assumes standard Pi OS layout)
    # Partition 1 (boot): usually starts at 2048 * 512 = 1048576
    # Partition 2 (root): usually starts later

    echo "Finding partition offsets..."

    # Using losetup to find offsets automatically
    local loop_device=$(losetup -f)
    losetup "$loop_device" "$image"

    # Find partitions
    local boot_part=""
    local root_part=""

    for part in "$loop_device"p*; do
        if [ -b "$part" ]; then
            local sector=$(cat /sys/class/block/$(basename "$part")/start)
            if [ "$sector" -lt 1000000 ]; then
                boot_part="$part"
                echo "Boot partition: $part (sector $sector)"
            else
                root_part="$part"
                echo "Root partition: $part (sector $sector)"
            fi
        fi
    done

    if [ -z "$boot_part" ] || [ -z "$root_part" ]; then
        echo_error "Could not find partitions in image"
        losetup -d "$loop_device"
        exit 1
    fi

    # Mount partitions
    mkdir -p "$MOUNT_DIR/root"
    mkdir -p "$MOUNT_DIR/boot"

    mount "$root_part" "$MOUNT_DIR" || exit 1
    mount "$boot_part" "$MOUNT_DIR/boot" || exit 1

    echo_success "Image mounted at $MOUNT_DIR"
    log "Mounted $root_part at $MOUNT_DIR"
    log "Mounted $boot_part at $MOUNT_DIR/boot"
}

customize_hostname() {
    echo_header "Customizing Hostname"

    # Set hostname
    echo "pentaos" > "$MOUNT_DIR/etc/hostname"

    # Update hosts file
    sed -i 's/raspberrypi/pentaos/g' "$MOUNT_DIR/etc/hosts"

    echo_success "Hostname set to 'pentaos'"
}

customize_wallpaper() {
    echo_header "Setting Default Wallpaper"

    local wallpaper_src="$PROJECT_ROOT/branding/pentaos-wallpaper.svg"
    local wallpaper_dest="$MOUNT_DIR/usr/share/pixmaps/pentaos-wallpaper.svg"

    if [ -f "$wallpaper_src" ]; then
        cp "$wallpaper_src" "$wallpaper_dest"
        chmod 644 "$wallpaper_dest"
        echo_success "Wallpaper installed"
    else
        echo_warning "Wallpaper not found, skipping"
    fi
}

customize_branding() {
    echo_header "Adding PentaOS Branding"

    local logo_src="$PROJECT_ROOT/branding/pentaos-logo.svg"
    local logo_dest="$MOUNT_DIR/usr/share/pixmaps/pentaos-logo.svg"

    if [ -f "$logo_src" ]; then
        cp "$logo_src" "$logo_dest"
        chmod 644 "$logo_dest"
        echo_success "Logo installed"
    fi

    # Create branding directory
    mkdir -p "$MOUNT_DIR/etc/pentaos"
    echo "PentaOS v1.0.0-alpha" > "$MOUNT_DIR/etc/pentaos/version"
    echo "Release: Raspberry Pi OS Bookworm with PentaOS Customizations" > "$MOUNT_DIR/etc/pentaos/release"
}

customize_motd() {
    echo_header "Creating Welcome Message"

    cat > "$MOUNT_DIR/etc/motd" << 'EOF'
 _____ _____ _____ _____ _____ _____
|  _  | ___ |  _  |_   _|  _  |  _  |
| |_| | |_/ | | | | | | | | | | | | |
|  _  |    \ | | | | | | | | | | | | |
| | | | |\ \\ |_| | | | | |_| | |_| |
\_| |_\_| \_|\___/  \_/  \___/|_____/

Welcome to PentaOS v1.0.0-alpha
Multi-core Excellence for Raspberry Pi

For more information, visit: https://github.com/jgm240/pentaos
Documentation: https://github.com/jgm240/pentaos/docs

Default login: pi / raspberry
(Change password immediately!)

Happy computing!
EOF

    echo_success "Welcome message created"
}

add_boot_splash() {
    echo_header "Adding Boot Splash"

    # Create a simple splash screen configuration
    cat > "$MOUNT_DIR/boot/firmware/boot-splash.txt" << 'EOF'
# PentaOS Boot Configuration
# Pentagon-themed operating system for Raspberry Pi

disable_overscan=1
dtoverlay=vc4-fkms-v3d
gpu_mem=128
EOF

    echo_success "Boot configuration added"
}

preinstall_packages() {
    echo_header "Pre-installing Useful Packages"

    # Create a script to run on first boot
    cat > "$MOUNT_DIR/usr/local/bin/pentaos-first-setup" << 'EOF'
#!/bin/bash
# First-time setup for PentaOS
# This runs on first boot to install additional packages

echo "PentaOS First-Time Setup"
echo "Updating system..."

apt-get update
apt-get install -y \
    git \
    curl \
    wget \
    vim \
    nano \
    htop \
    python3 \
    python3-pip \
    build-essential \
    libssl-dev \
    libffi-dev \
    2>&1 | grep -v "^Get:" | grep -v "^Reading"

echo "First-time setup complete!"
EOF

    chmod +x "$MOUNT_DIR/usr/local/bin/pentaos-first-setup"
    echo_success "Packages pre-configured for installation"
}

customize_login() {
    echo_header "Customizing Login Screen"

    # Add PentaOS to the login issue banner
    cat > "$MOUNT_DIR/etc/issue.net" << 'EOF'
\n                    PentaOS v1.0.0-alpha
          Multi-core Excellence for Raspberry Pi
\n                   https://github.com/jgm240/pentaos

EOF

    echo_success "Login screen customized"
}

create_readme() {
    echo_header "Creating PentaOS README"

    cat > "$MOUNT_DIR/home/pi/PENTAOS_README.txt" << 'EOF'
=====================================
Welcome to PentaOS!
=====================================

This is a customized Raspberry Pi OS with PentaOS branding and tools.

FIRST STEPS:
1. Change your password: passwd
2. Update the system: sudo apt update && sudo apt upgrade
3. Run setup: sudo pentaos-first-setup (optional)

PENTAOS FEATURES:
- Beautiful pentagon branding and wallpaper
- Accessibility tools for all users
- Compatibility layer (Wine, Box64, Box86)
- Multiple desktop environments available
- Lightweight and optimized for Raspberry Pi

INSTALL ADDITIONAL TOOLS:
- Desktop environments: sudo build/setup-desktop.sh
- Compatibility layer: sudo build/install-compatibility-layer.sh
- Accessibility tools: sudo build/install-accessibility-tools.sh

DOCUMENTATION:
See /root/pentaos/docs/ for complete guides

COMMUNITY:
- GitHub: https://github.com/jgm240/pentaos
- Issues: https://github.com/jgm240/pentaos/issues

Enjoy PentaOS!
EOF

    chown 1000:1000 "$MOUNT_DIR/home/pi/PENTAOS_README.txt"
    echo_success "README created"
}

finalize_image() {
    echo_header "Finalizing Image"

    # Sync filesystem
    sync

    echo_success "Image customization complete"
}

main() {
    check_root

    touch "$LOG_FILE"
    log "PentaOS image customization started"

    echo_header "PentaOS Image Customization Tool"
    echo ""
    echo "This will customize a Raspberry Pi OS image with PentaOS"
    echo "features, branding, and pre-configured tools."
    echo ""

    check_image
    cleanup_mounts

    # Extract the image first if compressed
    if [ -f "$IMAGES_DIR/2024-10-04-raspios-bookworm-arm64.img.xz" ] && [ ! -f "$IMAGES_DIR/2024-10-04-raspios-bookworm-arm64.img" ]; then
        echo_header "Extracting Image"
        cd "$IMAGES_DIR"
        xz -d -k 2024-10-04-raspios-bookworm-arm64.img.xz || true
        cd - > /dev/null
    fi

    setup_mounts

    # Run customizations
    customize_hostname
    customize_wallpaper
    customize_branding
    customize_motd
    customize_login
    add_boot_splash
    preinstall_packages
    create_readme
    finalize_image

    # Cleanup
    cleanup_mounts

    echo ""
    echo_header "Customization Complete!"
    echo ""
    echo "Next steps:"
    echo "1. Create compressed image: xz -k $IMAGES_DIR/2024-10-04-raspios-bookworm-arm64.img"
    echo "2. Flash to SD card: sudo dd if=$IMAGES_DIR/2024-10-04-raspios-bookworm-arm64.img of=/dev/sdX bs=4M status=progress"
    echo ""

    log "PentaOS image customization completed successfully"
}

main "$@"
