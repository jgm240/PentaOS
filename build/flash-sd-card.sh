#!/bin/bash

# PentaOS Flash SD Card Script
# Flashes PentaOS image to an SD card

set -e

# Check if device is provided
if [ $# -eq 0 ]; then
    echo "Usage: sudo $0 /dev/sdX"
    echo ""
    echo "Warning: This will erase all data on the target device!"
    echo ""
    echo "To find your SD card device:"
    echo "  lsblk      # List all block devices"
    echo "  dmesg      # Check system messages after inserting SD card"
    echo ""
    echo "Example: sudo $0 /dev/sdb"
    exit 1
fi

TARGET_DEVICE="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
IMAGES_DIR="$PROJECT_ROOT/images"
IMAGE_FILE="$IMAGES_DIR/pentaos-1.0.0-arm64.img"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}===============================================${NC}"
echo -e "${YELLOW}PentaOS SD Card Flasher${NC}"
echo -e "${YELLOW}===============================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run with sudo${NC}"
    exit 1
fi

# Check if image exists
if [ ! -f "$IMAGE_FILE" ]; then
    echo -e "${RED}Error: Image not found at $IMAGE_FILE${NC}"
    echo ""
    echo "Build the image first with:"
    echo "  ./build/build-pentaos.sh"
    exit 1
fi

# Confirm device
echo -e "${YELLOW}WARNING: About to erase ${RED}$TARGET_DEVICE${YELLOW}${NC}"
echo ""
echo "Current partitions on $TARGET_DEVICE:"
lsblk "$TARGET_DEVICE" 2>/dev/null || echo "  (Device not found)"
echo ""
read -p "Type 'yes' to proceed: " -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Flashing cancelled${NC}"
    exit 0
fi

# Unmount any mounted partitions
echo -e "${YELLOW}Unmounting any mounted partitions...${NC}"
for partition in "$TARGET_DEVICE"*; do
    if mountpoint -q "$partition" 2>/dev/null; then
        echo "  Unmounting $partition..."
        umount "$partition" || true
    fi
done

# Flash image
echo -e "${YELLOW}Flashing PentaOS to $TARGET_DEVICE...${NC}"
echo "This may take several minutes..."
echo ""

if dd if="$IMAGE_FILE" of="$TARGET_DEVICE" bs=4M status=progress conv=fsync 2>&1; then
    echo ""
    echo -e "${GREEN}===============================================${NC}"
    echo -e "${GREEN}Successfully flashed PentaOS!${NC}"
    echo -e "${GREEN}===============================================${NC}"
    echo ""
    echo "Remove the SD card and insert it into your Raspberry Pi"
    echo "Default credentials:"
    echo "  Username: pi"
    echo "  Password: raspberry"
    echo ""
    echo "First login steps:"
    echo "  1. Run: sudo raspi-config"
    echo "  2. Configure localization settings"
    echo "  3. Expand filesystem"
    echo "  4. Change password (important!)"
    echo ""
else
    echo -e "${RED}===============================================${NC}"
    echo -e "${RED}Flashing failed!${NC}"
    echo -e "${RED}===============================================${NC}"
    exit 1
fi
