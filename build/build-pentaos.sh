#!/bin/bash

# PentaOS Build Script
# This script builds PentaOS from Raspberry Pi OS base

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
WORK_DIR="${PROJECT_ROOT}/build"
OUTPUT_DIR="${PROJECT_ROOT}/images"

# Raspberry Pi OS base image to build from
RPI_OS_RELEASE_DIR="raspios_lite_arm64-2026-06-19"
RPI_OS_IMAGE="2026-06-18-raspios-trixie-arm64-lite.img"
PENTAOS_VERSION="1.0.0-alpha"

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

    if [ -f "$OUTPUT_DIR/${RPI_OS_IMAGE}.xz" ]; then
        echo -e "${GREEN}✓ Raspberry Pi OS already downloaded${NC}"
        return 0
    fi

    # Latest Raspberry Pi OS 64-bit Lite image URL
    RPM_OS_URL="https://downloads.raspberrypi.com/raspios_lite_arm64/images/${RPI_OS_RELEASE_DIR}/${RPI_OS_IMAGE}.xz"

    echo "Downloading from: $RPM_OS_URL"
    if wget -q --show-progress -O "$OUTPUT_DIR/${RPI_OS_IMAGE}.xz" "$RPM_OS_URL"; then
        echo -e "${GREEN}✓ Download completed${NC}"
    else
        echo -e "${RED}✗ Download failed${NC}"
        exit 1
    fi
}

# Extract image
extract_image() {
    echo -e "${YELLOW}Extracting Raspberry Pi OS image...${NC}"

    local image_xz="$OUTPUT_DIR/${RPI_OS_IMAGE}.xz"
    local image_img="$OUTPUT_DIR/${RPI_OS_IMAGE}"

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
    # 2. Copy custom files (setup scripts, branding)
    # 3. Modify configuration files
    # 4. Set up first-boot systemd service
    # 5. Update splash screens
    # 6. Unmount the image

    echo -e "${YELLOW}Note: Full image customization requires elevated privileges${NC}"
    echo -e "${YELLOW}To complete: sudo ./build/customize-rpi-image.sh (or sudo ./build/release-image.sh for a compressed release)${NC}"

    # Copy setup scripts to standard location for reference
    mkdir -p "$WORK_DIR/setup-files"
    cp "$SCRIPT_DIR/setup-desktop.sh" "$WORK_DIR/setup-files/"
    cp "$SCRIPT_DIR/pentaos-first-boot.sh" "$WORK_DIR/setup-files/"
    cp "$SCRIPT_DIR/pentaos-first-boot.service" "$WORK_DIR/setup-files/"

    echo -e "${YELLOW}Setup scripts prepared in: $WORK_DIR/setup-files/${NC}"
}

# Print build information
print_build_info() {
    echo ""
    echo -e "${GREEN}===============================================${NC}"
    echo -e "${GREEN}Download complete!${NC}"
    echo -e "${GREEN}===============================================${NC}"
    echo ""
    echo -e "Raspberry Pi OS base image: ${YELLOW}$OUTPUT_DIR/${RPI_OS_IMAGE}${NC}"
    echo ""
    echo "This is still an unmodified Raspberry Pi OS image - it has none of"
    echo "PentaOS's branding or first-boot setup baked in yet. Do NOT flash it"
    echo "directly. Next steps:"
    echo ""
    echo "1. Customize it in place:"
    echo "   ${YELLOW}sudo $SCRIPT_DIR/customize-rpi-image.sh${NC}"
    echo ""
    echo "2. Or build a full compressed release (customize + compress + checksums):"
    echo "   ${YELLOW}sudo $SCRIPT_DIR/release-image.sh${NC}"
    echo "   ${YELLOW}-> produces ${PROJECT_ROOT}/releases/pentaos-${PENTAOS_VERSION}-arm64.img.xz${NC}"
    echo ""
    echo "Only flash the image *after* one of the above has customized it."
    echo ""
}

# Main build process
main() {
    check_requirements
    download_rpi_os
    extract_image
    customize_image
    print_build_info
}

main "$@"
