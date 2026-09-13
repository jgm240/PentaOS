#!/bin/bash

# PentaOS Build Script
# This script builds PentaOS from Raspberry Pi OS base

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
WORK_DIR="${PROJECT_ROOT}/build"
OUTPUT_DIR="${PROJECT_ROOT}/images"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}===============================================${NC}"
echo -e "${GREEN}PentaOS Build System${NC}"
echo -e "${GREEN}===============================================${NC}"

# Check for required tools
check_requirements() {
    echo -e "${YELLOW}Checking system requirements...${NC}"

    local missing_tools=()

    if ! command -v wget &> /dev/null; then
        missing_tools+=("wget")
    fi

    if ! command -v xz &> /dev/null; then
        missing_tools+=("xz-utils")
    fi

    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${RED}Missing required tools: ${missing_tools[*]}${NC}"
        echo "Install with: sudo apt-get install ${missing_tools[*]}"
        exit 1
    fi

    echo -e "${GREEN}✓ All requirements met${NC}"
}

# Download Raspberry Pi OS
download_rpi_os() {
    echo -e "${YELLOW}Downloading Raspberry Pi OS...${NC}"

    mkdir -p "$OUTPUT_DIR"

    if [ -f "$OUTPUT_DIR/2024-10-04-raspios-bookworm-arm64.img.xz" ]; then
        echo -e "${GREEN}✓ Raspberry Pi OS already downloaded${NC}"
        return 0
    fi

    # Latest Raspberry Pi OS 64-bit Lite image URL
    RPM_OS_URL="https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2024-10-04/2024-10-04-raspios-bookworm-arm64.img.xz"

    echo "Downloading from: $RPM_OS_URL"
    if wget -q --show-progress -O "$OUTPUT_DIR/2024-10-04-raspios-bookworm-arm64.img.xz" "$RPM_OS_URL"; then
        echo -e "${GREEN}✓ Download completed${NC}"
    else
        echo -e "${RED}✗ Download failed${NC}"
        exit 1
    fi
}

# Extract image
extract_image() {
    echo -e "${YELLOW}Extracting Raspberry Pi OS image...${NC}"

    local image_xz="$OUTPUT_DIR/2024-10-04-raspios-bookworm-arm64.img.xz"
    local image_img="$OUTPUT_DIR/2024-10-04-raspios-bookworm-arm64.img"

    if [ -f "$image_img" ]; then
        echo -e "${GREEN}✓ Image already extracted${NC}"
        return 0
    fi

    if xz -d -k "$image_xz"; then
        echo -e "${GREEN}✓ Image extracted${NC}"
    else
        echo -e "${RED}✗ Extraction failed${NC}"
        exit 1
    fi
}

# Customize image with PentaOS branding
customize_image() {
    echo -e "${YELLOW}Customizing image with PentaOS branding...${NC}"

    # This is a placeholder for image customization
    # In a real scenario, you would:
    # 1. Mount the image
    # 2. Copy custom files
    # 3. Modify configuration files
    # 4. Update splash screens
    # 5. Unmount the image

    echo -e "${YELLOW}Note: Full image customization requires elevated privileges${NC}"
    echo -e "${YELLOW}To complete: sudo ./build/customize-image.sh${NC}"
}

# Create PentaOS image
create_pentaos_image() {
    echo -e "${YELLOW}Creating PentaOS image...${NC}"

    local source_img="$OUTPUT_DIR/2024-10-04-raspios-bookworm-arm64.img"
    local pentaos_img="$OUTPUT_DIR/pentaos-1.0.0-arm64.img"

    if [ -f "$pentaos_img" ]; then
        echo -e "${GREEN}✓ PentaOS image already created${NC}"
        return 0
    fi

    # Copy the Raspberry Pi OS image as PentaOS base
    if cp "$source_img" "$pentaos_img"; then
        echo -e "${GREEN}✓ PentaOS image created${NC}"
    else
        echo -e "${RED}✗ Failed to create PentaOS image${NC}"
        exit 1
    fi
}

# Print build information
print_build_info() {
    echo ""
    echo -e "${GREEN}===============================================${NC}"
    echo -e "${GREEN}Build completed successfully!${NC}"
    echo -e "${GREEN}===============================================${NC}"
    echo ""
    echo -e "PentaOS Image: ${YELLOW}$OUTPUT_DIR/pentaos-1.0.0-arm64.img${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Flash to SD card:"
    echo "   ${YELLOW}sudo dd if=$OUTPUT_DIR/pentaos-1.0.0-arm64.img of=/dev/sdX bs=4M status=progress${NC}"
    echo ""
    echo "2. Or use the flash script:"
    echo "   ${YELLOW}sudo $SCRIPT_DIR/flash-sd-card.sh /dev/sdX${NC}"
    echo ""
}

# Main build process
main() {
    check_requirements
    download_rpi_os
    extract_image
    customize_image
    create_pentaos_image
    print_build_info
}

main "$@"
