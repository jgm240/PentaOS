#!/bin/bash

# PentaOS Desktop Environment Setup
# Interactive setup script to choose between GNOME, KDE, or default Pi Desktop
# Runs on first boot if internet is available

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="/var/log/pentaos-setup.log"

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

# Check internet connectivity
check_internet() {
    echo_header "Checking Internet Connectivity"

    # Try multiple DNS servers to ensure connectivity
    for dns in 8.8.8.8 1.1.1.1 208.67.222.222; do
        if ping -c 1 -W 2 "$dns" > /dev/null 2>&1; then
            echo_success "Internet connection detected"
            return 0
        fi
    done

    echo_warning "No internet connection detected"
    return 1
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

# Install GNOME Desktop
install_gnome() {
    echo_header "Installing GNOME Desktop"
    echo_warning "This may take 15-30 minutes on slower connections"

    log "Starting GNOME installation"

    if apt-get install -y gnome-desktop-environment gnome-shell gdm3 > "$LOG_FILE" 2>&1; then
        echo_success "GNOME Desktop installed successfully"
        log "GNOME installation completed"
        return 0
    else
        echo_error "Failed to install GNOME"
        log "GNOME installation failed"
        return 1
    fi
}

# Install KDE Plasma Desktop
install_kde() {
    echo_header "Installing KDE Plasma Desktop"
    echo_warning "This may take 20-40 minutes on slower connections"

    log "Starting KDE Plasma installation"

    if apt-get install -y kde-plasma-desktop sddm > "$LOG_FILE" 2>&1; then
        echo_success "KDE Plasma Desktop installed successfully"
        log "KDE installation completed"
        return 0
    else
        echo_error "Failed to install KDE Plasma"
        log "KDE installation failed"
        return 1
    fi
}

# Install Raspberry Pi Desktop (default - lighter weight)
install_pi_desktop() {
    echo_header "Installing Raspberry Pi Desktop"
    echo_warning "This may take 10-20 minutes"

    log "Starting Raspberry Pi Desktop installation"

    if apt-get install -y raspberrypi-ui-mods lightdm > "$LOG_FILE" 2>&1; then
        echo_success "Raspberry Pi Desktop installed successfully"
        log "Pi Desktop installation completed"
        return 0
    else
        echo_error "Failed to install Raspberry Pi Desktop"
        log "Pi Desktop installation failed"
        return 1
    fi
}

# Configure display manager
configure_display_manager() {
    local dm=$1

    echo_header "Configuring Display Manager"

    case "$dm" in
        gnome)
            if command -v update-alternatives > /dev/null; then
                update-alternatives --set x-session-manager /usr/bin/gnome-session 2>/dev/null || true
                echo_success "GNOME configured as default session"
            fi
            ;;
        kde)
            if command -v update-alternatives > /dev/null; then
                update-alternatives --set x-session-manager /usr/bin/startplasma-x11 2>/dev/null || true
                echo_success "KDE configured as default session"
            fi
            ;;
        pi)
            if command -v update-alternatives > /dev/null; then
                update-alternatives --set x-session-manager /usr/bin/xfce4-session 2>/dev/null || true
                echo_success "Raspberry Pi Desktop configured as default session"
            fi
            ;;
    esac
}

# Display menu
show_menu() {
    echo ""
    echo -e "${BLUE}Choose Desktop Environment:${NC}"
    echo ""
    echo "  1) ${GREEN}GNOME${NC} - Feature-rich, modern desktop"
    echo "     Memory: Higher | Speed: Good | Features: Extensive"
    echo ""
    echo "  2) ${BLUE}KDE Plasma${NC} - Customizable, powerful desktop"
    echo "     Memory: High | Speed: Good | Features: Extensive"
    echo ""
    echo "  3) ${YELLOW}Raspberry Pi Desktop${NC} - Lightweight, optimized"
    echo "     Memory: Low | Speed: Excellent | Features: Basic"
    echo ""
    echo "  4) ${RED}None${NC} - Command-line only (headless)"
    echo "     Memory: Minimal | Speed: N/A | Features: None"
    echo ""
    read -p "Enter your choice (1-4): " choice
    echo "$choice"
}

# Cleanup function
cleanup() {
    echo_header "Cleaning Up"

    # Clean package cache
    apt-get clean > /dev/null 2>&1
    apt-get autoclean > /dev/null 2>&1
    apt-get autoremove -y > /dev/null 2>&1

    echo_success "Cleanup completed"
}

# Display system requirements
show_requirements() {
    echo ""
    echo -e "${BLUE}System Requirements:${NC}"
    echo ""
    echo "Desktop Environment | Min RAM | Recommended | Disk Space"
    echo "─────────────────────────────────────────────────────────"
    echo "GNOME               | 2GB     | 4GB+        | 3-4GB"
    echo "KDE Plasma          | 2GB     | 4GB+        | 3-4GB"
    echo "Pi Desktop (XFCE)   | 512MB   | 1GB+        | 1-2GB"
    echo "Headless (None)     | 256MB   | 512MB+      | 500MB"
    echo ""
}

# Get system info
show_system_info() {
    echo -e "${BLUE}System Information:${NC}"

    local ram_mb=$(free -m | awk '/^Mem:/{print $2}')
    local disk_gb=$(df / | awk 'NR==2 {printf "%.1f", $4/1024/1024}')
    local model=$(grep -oP 'Revision : \K.*' /proc/cpuinfo 2>/dev/null || echo "Unknown")

    echo "  Raspberry Pi Model: $model"
    echo "  Available RAM: ${ram_mb}MB"
    echo "  Free Disk Space: ${disk_gb}GB"
    echo ""
}

# Main setup function
main() {
    check_root

    echo_header "PentaOS Desktop Environment Setup"
    echo ""
    echo "This script will help you set up your preferred desktop environment"
    echo ""

    # Create log file
    touch "$LOG_FILE"
    log "PentaOS setup started"

    # Show system info
    show_system_info

    # Check internet
    if ! check_internet; then
        echo_warning "Internet connection required to install desktop environments"
        echo_warning "Skipping desktop installation"
        log "Internet not available, skipping installation"
        exit 0
    fi

    echo ""
    show_requirements

    # Get user choice
    choice=$(show_menu)

    case "$choice" in
        1)
            echo ""
            log "User selected GNOME"
            update_packages || exit 1
            install_gnome || exit 1
            configure_display_manager gnome
            cleanup
            echo_success "GNOME Desktop setup complete!"
            ;;
        2)
            echo ""
            log "User selected KDE Plasma"
            update_packages || exit 1
            install_kde || exit 1
            configure_display_manager kde
            cleanup
            echo_success "KDE Plasma Desktop setup complete!"
            ;;
        3)
            echo ""
            log "User selected Raspberry Pi Desktop"
            update_packages || exit 1
            install_pi_desktop || exit 1
            configure_display_manager pi
            cleanup
            echo_success "Raspberry Pi Desktop setup complete!"
            ;;
        4)
            echo ""
            log "User selected headless (no desktop)"
            echo_success "PentaOS configured for headless operation"
            ;;
        *)
            echo_error "Invalid choice. Skipping desktop installation."
            log "Invalid choice: $choice"
            exit 1
            ;;
    esac

    echo ""
    echo_header "Setup Complete"
    echo ""
    echo "Your PentaOS system is ready!"
    echo ""
    echo "Next steps:"
    echo "  1. Reboot your system: ${YELLOW}sudo reboot${NC}"
    echo "  2. Log in with your credentials"
    echo "  3. Start using your chosen desktop environment"
    echo ""
    echo "To change desktop later, run this script again:"
    echo "  ${YELLOW}sudo $(dirname "$0")/setup-desktop.sh${NC}"
    echo ""

    log "PentaOS setup completed successfully"
}

main "$@"
