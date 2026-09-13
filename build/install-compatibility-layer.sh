#!/bin/bash

# PentaOS Compatibility Layer Installation
# Installs Wine, Box64, and Box86 for running Windows and x86 applications on ARM

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="/var/log/pentaos-compatibility-install.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging function
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

echo_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

echo_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo_error "This script must be run with sudo"
        exit 1
    fi
}

# Check system architecture
check_architecture() {
    echo_header "Checking System Architecture"

    local arch=$(uname -m)
    log "System architecture: $arch"

    case "$arch" in
        aarch64)
            echo_success "ARM64 architecture detected"
            ARCH="arm64"
            ;;
        armv7l|armv6l)
            echo_success "ARMv7/ARMv6 architecture detected"
            ARCH="arm"
            ;;
        *)
            echo_error "Unsupported architecture: $arch"
            echo "Box64 requires ARM64 (aarch64)"
            echo "Box86 requires ARMv7/ARMv6"
            exit 1
            ;;
    esac
}

# Check system resources
check_resources() {
    echo_header "Checking System Resources"

    local ram_mb=$(free -m | awk '/^Mem:/{print $2}')
    local disk_gb=$(df / | awk 'NR==2 {printf "%.1f", $4/1024/1024}')

    echo "Available RAM: ${ram_mb}MB"
    echo "Free Disk Space: ${disk_gb}GB"

    if [ "$ram_mb" -lt 1024 ]; then
        echo_warning "Low RAM available (less than 1GB)"
        echo_warning "Performance may be degraded"
    fi

    if [ $(echo "$disk_gb < 5" | bc) -eq 1 ]; then
        echo_error "Insufficient disk space (less than 5GB)"
        exit 1
    fi

    echo_success "System resources adequate"
}

# Update package lists
update_packages() {
    echo_header "Updating Package Lists"

    if ! apt-get update > /dev/null 2>&1; then
        echo_error "Failed to update package lists"
        return 1
    fi

    echo_success "Package lists updated"
    return 0
}

# Install Box64 (for ARM64 systems)
install_box64() {
    echo_header "Installing Box64"
    echo_warning "Box64 is required for ARM64 to run x86-64 binaries"

    log "Starting Box64 installation"

    if [ "$ARCH" != "arm64" ]; then
        echo_warning "Skipping Box64 (requires ARM64 architecture)"
        return 0
    fi

    # Install dependencies
    echo "Installing Box64 dependencies..."
    apt-get install -y \
        cmake \
        build-essential \
        git \
        libelf-dev \
        libdw-dev \
        binutils-dev \
        libiberty-dev \
        pkg-config > /dev/null 2>&1

    # Clone and build Box64
    if [ ! -d /opt/box64 ]; then
        echo "Cloning Box64 repository..."
        git clone https://github.com/ptitSeb/box64.git /opt/box64 2>&1 | tail -5
    else
        echo "Box64 directory already exists, updating..."
        cd /opt/box64 && git pull > /dev/null 2>&1
    fi

    cd /opt/box64
    mkdir -p build
    cd build

    echo "Configuring Box64..."
    cmake -DBOX64_ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo .. > /dev/null 2>&1

    echo "Building Box64 (this may take several minutes)..."
    make -j$(nproc) > /dev/null 2>&1

    echo "Installing Box64..."
    make install > /dev/null 2>&1

    # Create symlinks
    ln -sf /opt/box64/build/box64 /usr/local/bin/box64 || true

    if command -v box64 &> /dev/null; then
        echo_success "Box64 installed successfully"
        log "Box64 installation completed"
    else
        echo_error "Box64 installation failed"
        log "Box64 installation failed"
        return 1
    fi

    cd "$SCRIPT_DIR"
}

# Install Box86 (for ARMv7/ARMv6 systems)
install_box86() {
    echo_header "Installing Box86"
    echo_warning "Box86 is required for ARMv7/ARMv6 to run x86 binaries"

    log "Starting Box86 installation"

    # Install dependencies
    echo "Installing Box86 dependencies..."
    apt-get install -y \
        cmake \
        build-essential \
        git \
        libelf-dev \
        libdw-dev \
        binutils-dev \
        libiberty-dev \
        pkg-config > /dev/null 2>&1

    # Clone and build Box86
    if [ ! -d /opt/box86 ]; then
        echo "Cloning Box86 repository..."
        git clone https://github.com/ptitSeb/box86.git /opt/box86 2>&1 | tail -5
    else
        echo "Box86 directory already exists, updating..."
        cd /opt/box86 && git pull > /dev/null 2>&1
    fi

    cd /opt/box86
    mkdir -p build
    cd build

    echo "Configuring Box86..."
    cmake -DBOX86_DYNAREC=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo .. > /dev/null 2>&1

    echo "Building Box86 (this may take several minutes)..."
    make -j$(nproc) > /dev/null 2>&1

    echo "Installing Box86..."
    make install > /dev/null 2>&1

    # Create symlinks
    ln -sf /opt/box86/build/box86 /usr/local/bin/box86 || true

    if command -v box86 &> /dev/null; then
        echo_success "Box86 installed successfully"
        log "Box86 installation completed"
    else
        echo_error "Box86 installation failed"
        log "Box86 installation failed"
        return 1
    fi

    cd "$SCRIPT_DIR"
}

# Install Wine
install_wine() {
    echo_header "Installing Wine"

    log "Starting Wine installation"

    echo "Installing Wine dependencies..."
    apt-get install -y \
        wine \
        wine32 \
        wine64 \
        winetricks \
        fonts-liberation \
        fonts-dejavu > /dev/null 2>&1

    # Configure Wine for first use
    if [ ! -d ~/.wine ]; then
        echo "Initializing Wine prefix..."
        WINEARCH=win64 wineboot --init > /dev/null 2>&1 || true
    fi

    if command -v wine &> /dev/null; then
        echo_success "Wine installed successfully"
        echo "Wine version: $(wine --version)"
        log "Wine installation completed"
    else
        echo_error "Wine installation failed"
        log "Wine installation failed"
        return 1
    fi
}

# Install Winetricks (already included above, but document it)
setup_winetricks() {
    echo_header "Setting Up Winetricks"

    log "Configuring Winetricks for common applications"

    echo "Winetricks is available for installing Windows components:"
    echo "  winetricks dotnet48      # Install .NET Framework"
    echo "  winetricks vcrun2019      # Install Visual C++ Runtime"
    echo "  winetricks d3dx9          # Install DirectX 9"
    echo "  winetricks corefonts      # Install standard Windows fonts"
    echo ""

    echo_success "Winetricks configured"
}

# Create launcher scripts
create_launchers() {
    echo_header "Creating Launcher Scripts"

    # Box64 launcher
    cat > /usr/local/bin/run-x86-64 << 'EOF'
#!/bin/bash
# Run x86-64 applications with Box64
if [ $# -eq 0 ]; then
    echo "Usage: run-x86-64 <program> [arguments]"
    exit 1
fi

export BOX64_DYNAREC=1
box64 "$@"
EOF
    chmod +x /usr/local/bin/run-x86-64

    # Box86 launcher
    cat > /usr/local/bin/run-x86-32 << 'EOF'
#!/bin/bash
# Run x86 32-bit applications with Box86
if [ $# -eq 0 ]; then
    echo "Usage: run-x86-32 <program> [arguments]"
    exit 1
fi

export BOX86_DYNAREC=1
box86 "$@"
EOF
    chmod +x /usr/local/bin/run-x86-32

    # Wine launcher
    cat > /usr/local/bin/run-windows << 'EOF'
#!/bin/bash
# Run Windows applications with Wine
if [ $# -eq 0 ]; then
    echo "Usage: run-windows <program.exe> [arguments]"
    exit 1
fi

wine "$@"
EOF
    chmod +x /usr/local/bin/run-windows

    echo_success "Launcher scripts created"
    echo ""
    echo "Available commands:"
    echo "  run-x86-64 <program>  - Run x86-64 applications"
    echo "  run-x86-32 <program>  - Run x86 32-bit applications"
    echo "  run-windows <app.exe> - Run Windows applications"
}

# Configuration menu
show_menu() {
    echo ""
    echo -e "${BLUE}Select compatibility layer components to install:${NC}"
    echo ""
    echo "  1) Wine only"
    echo "  2) Box64 only (ARM64 required)"
    echo "  3) Box86 only (ARMv7/ARMv6 required)"
    echo "  4) Wine + Box64 (recommended for ARM64)"
    echo "  5) Wine + Box86 (recommended for ARMv7/ARMv6)"
    echo "  6) Install all components"
    echo "  7) Cancel"
    echo ""
    read -p "Enter your choice (1-7): " choice
    echo "$choice"
}

# Cleanup function
cleanup() {
    echo_header "Cleaning Up"

    apt-get clean > /dev/null 2>&1
    apt-get autoclean > /dev/null 2>&1
    apt-get autoremove -y > /dev/null 2>&1

    echo_success "Cleanup completed"
}

# Main installation function
main() {
    check_root

    touch "$LOG_FILE"
    log "PentaOS compatibility layer installation started"

    echo_header "PentaOS Compatibility Layer Installation"
    echo ""
    echo "This script installs Wine, Box64, and Box86 for running"
    echo "Windows and x86 applications on your Raspberry Pi."
    echo ""

    check_architecture
    check_resources

    if ! update_packages; then
        echo_error "Failed to update packages"
        exit 1
    fi

    choice=$(show_menu)

    case "$choice" in
        1)
            log "User selected Wine only"
            install_wine
            setup_winetricks
            create_launchers
            ;;
        2)
            log "User selected Box64 only"
            if [ "$ARCH" != "arm64" ]; then
                echo_error "Box64 requires ARM64 architecture"
                exit 1
            fi
            install_box64
            create_launchers
            ;;
        3)
            log "User selected Box86 only"
            install_box86
            create_launchers
            ;;
        4)
            log "User selected Wine + Box64"
            if [ "$ARCH" != "arm64" ]; then
                echo_error "Box64 requires ARM64 architecture"
                exit 1
            fi
            install_box64
            install_wine
            setup_winetricks
            create_launchers
            ;;
        5)
            log "User selected Wine + Box86"
            install_box86
            install_wine
            setup_winetricks
            create_launchers
            ;;
        6)
            log "User selected install all components"
            if [ "$ARCH" = "arm64" ]; then
                install_box64
            fi
            install_box86 || true
            install_wine
            setup_winetricks
            create_launchers
            ;;
        7)
            echo_warning "Installation cancelled"
            exit 0
            ;;
        *)
            echo_error "Invalid choice"
            exit 1
            ;;
    esac

    cleanup

    echo ""
    echo_header "Installation Complete"
    echo ""
    echo "Compatibility layers have been installed successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. Run Windows apps: ${YELLOW}wine app.exe${NC}"
    echo "  2. Run x86-64 apps: ${YELLOW}box64 app${NC}"
    echo "  3. Run x86-32 apps: ${YELLOW}box86 app${NC}"
    echo ""
    echo "Documentation: See docs/COMPATIBILITY-LAYER.md"
    echo ""

    log "PentaOS compatibility layer installation completed successfully"
}

main "$@"
