#!/bin/bash

# PentaOS Image Customization Script
# Customizes a Raspberry Pi OS image with PentaOS branding and tools.
#
# The boot partition (FAT32) is edited with mtools and the root partition
# (ext4) is edited via an offset-based loop mount. Neither technique
# depends on kernel loop-partition scanning (`losetup -P`) or a `vfat`
# kernel module, so this works in restricted/CI containers as well as on
# a full Linux host with root privileges.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
IMAGES_DIR="${PROJECT_ROOT}/images"
MOUNT_DIR="/mnt/pentaos-build"
LOG_FILE="/var/log/pentaos-customize.log"

RPI_OS_IMAGE="${RPI_OS_IMAGE:-2026-06-18-raspios-trixie-arm64-lite.img}"
PENTAOS_VERSION="${PENTAOS_VERSION:-1.0.0-alpha}"

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

echo_success() { echo -e "${GREEN}✓ $1${NC}"; }
echo_error() { echo -e "${RED}✗ $1${NC}"; }
echo_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo_error "This script must be run with sudo"
        exit 1
    fi
}

check_image() {
    if [ ! -f "$IMAGES_DIR/$RPI_OS_IMAGE" ]; then
        echo_error "Raspberry Pi OS image not found: $IMAGES_DIR/$RPI_OS_IMAGE"
        echo "Run: ./build/build-pentaos.sh first"
        exit 1
    fi
    echo_success "Base image found"
}

cleanup_mounts() {
    echo_header "Cleaning Up Mounts"

    if mountpoint -q "$MOUNT_DIR" 2>/dev/null; then
        umount "$MOUNT_DIR" || true
    fi

    # Detach any loop device still attached to our image
    local image="$IMAGES_DIR/$RPI_OS_IMAGE"
    for dev in $(losetup -j "$image" 2>/dev/null | cut -d: -f1); do
        losetup -d "$dev" || true
    done

    [ -d "$MOUNT_DIR" ] && rmdir "$MOUNT_DIR" 2>/dev/null || true

    echo_success "Mounts cleaned"
}

# Reads the boot/root partition start sector + sector count (512-byte
# sectors) from the image's partition table into BOOT_START/BOOT_SIZE and
# ROOT_START/ROOT_SIZE.
read_partition_table() {
    local image="$1"

    local table
    table="$(sfdisk -J "$image")"

    BOOT_START=$(echo "$table" | python3 -c "import json,sys; d=json.load(sys.stdin)['partitiontable']['partitions']; print(d[0]['start'])")
    BOOT_SIZE=$(echo "$table" | python3 -c "import json,sys; d=json.load(sys.stdin)['partitiontable']['partitions']; print(d[0]['size'])")
    ROOT_START=$(echo "$table" | python3 -c "import json,sys; d=json.load(sys.stdin)['partitiontable']['partitions']; print(d[1]['start'])")
    ROOT_SIZE=$(echo "$table" | python3 -c "import json,sys; d=json.load(sys.stdin)['partitiontable']['partitions']; print(d[1]['size'])")

    if [ -z "$BOOT_START" ] || [ -z "$ROOT_START" ]; then
        echo_error "Could not read partition table from image"
        exit 1
    fi

    BOOT_OFFSET=$((BOOT_START * 512))
    ROOT_OFFSET=$((ROOT_START * 512))

    log "boot partition: start=$BOOT_START size=$BOOT_SIZE (offset $BOOT_OFFSET)"
    log "root partition: start=$ROOT_START size=$ROOT_SIZE (offset $ROOT_OFFSET)"
}

setup_root_mount() {
    echo_header "Mounting Root Partition"

    local image="$1"

    mkdir -p "$MOUNT_DIR"

    ROOT_LOOP=$(losetup -f --show -o "$ROOT_OFFSET" --sizelimit $((ROOT_SIZE * 512)) "$image")
    mount "$ROOT_LOOP" "$MOUNT_DIR" || {
        losetup -d "$ROOT_LOOP"
        echo_error "Failed to mount root partition"
        exit 1
    }

    echo_success "Root partition mounted at $MOUNT_DIR"
    log "Mounted root partition via $ROOT_LOOP at $MOUNT_DIR"
}

# Writes a local file into the FAT32 boot partition using mtools, directly
# against the disk image at the boot partition's byte offset. No mount
# (and therefore no vfat kernel driver) required.
boot_mcopy() {
    local local_file="$1"
    local dest_path="$2"
    mcopy -o -i "${IMAGE}@@${BOOT_OFFSET}" "$local_file" "::${dest_path}"
}

customize_hostname() {
    echo_header "Customizing Hostname"
    echo "pentaos" > "$MOUNT_DIR/etc/hostname"
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

    mkdir -p "$MOUNT_DIR/etc/pentaos"
    echo "PentaOS v${PENTAOS_VERSION}" > "$MOUNT_DIR/etc/pentaos/version"
    echo "Release: Raspberry Pi OS with PentaOS Customizations" > "$MOUNT_DIR/etc/pentaos/release"
}

customize_motd() {
    echo_header "Creating Welcome Message"

    cat > "$MOUNT_DIR/etc/motd" << EOF
 _____ _____ _____ _____ _____ _____
|  _  | ___ |  _  |_   _|  _  |  _  |
| |_| | |_/ | | | | | | | | | | | | |
|  _  |    \\ | | | | | | | | | | | | |
| | | | |\\ \\\\ |_| | | | | |_| | |_| |
\\_| |_\\_| \\_|\\___/  \\_/  \\___/|_____/

Welcome to PentaOS v${PENTAOS_VERSION}
Multi-core Excellence for Raspberry Pi

For more information, visit: https://github.com/jgm240/pentaos
Documentation: https://github.com/jgm240/pentaos/docs

Happy computing!
EOF

    echo_success "Welcome message created"
}

add_boot_splash() {
    echo_header "Adding Boot Configuration Notes"

    cat > /tmp/pentaos-boot-splash.txt << 'EOF'
# PentaOS Boot Configuration
# Pentagon-themed operating system for Raspberry Pi

disable_overscan=1
dtoverlay=vc4-fkms-v3d
gpu_mem=128
EOF

    boot_mcopy /tmp/pentaos-boot-splash.txt /boot-splash.txt
    rm -f /tmp/pentaos-boot-splash.txt

    echo_success "Boot configuration notes added to boot partition"
}

preinstall_packages() {
    echo_header "Pre-installing Useful Packages"

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

install_first_boot_service() {
    echo_header "Installing First-Boot Setup Service"

    cp "$SCRIPT_DIR/pentaos-first-boot.sh" "$MOUNT_DIR/usr/local/bin/pentaos-first-boot.sh"
    chmod +x "$MOUNT_DIR/usr/local/bin/pentaos-first-boot.sh"

    cp "$SCRIPT_DIR/pentaos-first-boot.service" "$MOUNT_DIR/etc/systemd/system/pentaos-first-boot.service"

    mkdir -p "$MOUNT_DIR/etc/systemd/system/multi-user.target.wants"
    ln -sf /etc/systemd/system/pentaos-first-boot.service \
        "$MOUNT_DIR/etc/systemd/system/multi-user.target.wants/pentaos-first-boot.service"

    cp "$SCRIPT_DIR/setup-desktop.sh" "$MOUNT_DIR/usr/local/bin/pentaos-setup-desktop"
    chmod +x "$MOUNT_DIR/usr/local/bin/pentaos-setup-desktop"

    echo_success "First-boot service enabled"
}

customize_login() {
    echo_header "Customizing Login Screen"

    cat > "$MOUNT_DIR/etc/issue.net" << EOF
\n                    PentaOS v${PENTAOS_VERSION}
          Multi-core Excellence for Raspberry Pi
\n                   https://github.com/jgm240/pentaos

EOF

    echo_success "Login screen customized"
}

create_readme() {
    echo_header "Creating PentaOS README"

    mkdir -p "$MOUNT_DIR/home/pi"
    cat > "$MOUNT_DIR/home/pi/PENTAOS_README.txt" << 'EOF'
=====================================
Welcome to PentaOS!
=====================================

This is a customized Raspberry Pi OS with PentaOS branding and tools.

FIRST STEPS:
1. Update the system: sudo apt update && sudo apt upgrade
2. Run setup: sudo pentaos-first-setup (optional)

PENTAOS FEATURES:
- Beautiful pentagon branding and wallpaper
- Accessibility tools for all users
- Compatibility layer (Wine, Box64, Box86)
- Multiple desktop environments available
- Lightweight and optimized for Raspberry Pi

INSTALL ADDITIONAL TOOLS:
- Desktop environments: sudo pentaos-setup-desktop
- Compatibility layer: sudo build/install-compatibility-layer.sh
- Accessibility tools: sudo build/install-accessibility-tools.sh

DOCUMENTATION:
See https://github.com/jgm240/pentaos/tree/main/docs for complete guides

COMMUNITY:
- GitHub: https://github.com/jgm240/pentaos
- Issues: https://github.com/jgm240/pentaos/issues

Enjoy PentaOS!
EOF

    chown -R 1000:1000 "$MOUNT_DIR/home/pi/PENTAOS_README.txt"
    echo_success "README created"
}

finalize_image() {
    echo_header "Finalizing Image"
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

    IMAGE="$IMAGES_DIR/$RPI_OS_IMAGE"

    # Extract the image first if compressed
    if [ -f "${IMAGE}.xz" ] && [ ! -f "$IMAGE" ]; then
        echo_header "Extracting Image"
        xz -d -k "${IMAGE}.xz"
    fi

    read_partition_table "$IMAGE"
    setup_root_mount "$IMAGE"

    # Root (ext4) customizations - direct filesystem edits via loop mount
    customize_hostname
    customize_wallpaper
    customize_branding
    customize_motd
    customize_login
    preinstall_packages
    install_first_boot_service
    create_readme
    finalize_image

    sync
    umount "$MOUNT_DIR"
    losetup -d "$ROOT_LOOP"
    rmdir "$MOUNT_DIR"

    # Boot (FAT32) customizations - via mtools, no mount required
    add_boot_splash

    echo ""
    echo_header "Customization Complete!"
    echo ""
    echo "Next steps:"
    echo "1. Create compressed image: xz -k $IMAGE"
    echo "2. Flash to SD card: sudo dd if=$IMAGE of=/dev/sdX bs=4M status=progress"
    echo ""

    log "PentaOS image customization completed successfully"
}

main "$@"
