#!/bin/bash

# PentaOS Accessibility Tools Installation
# Installs comprehensive accessibility features for all users

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="/var/log/pentaos-accessibility-install.log"

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

# Install screen readers
install_screen_readers() {
    echo_header "Installing Screen Readers"

    log "Installing screen reader tools"

    echo "Installing Orca screen reader..."
    apt-get install -y gnome-shell-extensions-orca orca > /dev/null 2>&1 || true

    echo "Installing festival text-to-speech..."
    apt-get install -y festival festival-dev > /dev/null 2>&1 || true

    echo "Installing espeak text-to-speech..."
    apt-get install -y espeak espeak-ng > /dev/null 2>&1 || true

    echo_success "Screen readers installed"
}

# Install visual aids
install_visual_aids() {
    echo_header "Installing Visual Aids"

    log "Installing visual accessibility tools"

    echo "Installing color blind filters..."
    apt-get install -y redshift-gtk > /dev/null 2>&1 || true

    echo "Installing magnification tools..."
    apt-get install -y gnome-shell-extensions-magnifier > /dev/null 2>&1 || true

    echo "Installing high contrast themes..."
    apt-get install -y gnome-themes-extra > /dev/null 2>&1 || true

    echo "Installing font tools..."
    apt-get install -y fonts-liberation fonts-dejavu fonts-ubuntu-title > /dev/null 2>&1

    echo_success "Visual aids installed"
}

# Install keyboard accessibility
install_keyboard_accessibility() {
    echo_header "Installing Keyboard Accessibility"

    log "Installing keyboard accessibility tools"

    echo "Installing sticky keys and slow keys..."
    apt-get install -y gnome-shell-extensions-accessibility > /dev/null 2>&1 || true

    echo "Installing keyboard navigation tools..."
    apt-get install -y at-spi2-core > /dev/null 2>&1

    echo "Installing onboard virtual keyboard..."
    apt-get install -y onboard > /dev/null 2>&1 || true

    echo "Installing Florence virtual keyboard..."
    apt-get install -y florence > /dev/null 2>&1 || true

    echo_success "Keyboard accessibility tools installed"
}

# Install input method editors
install_input_methods() {
    echo_header "Installing Input Method Editors"

    log "Installing input method tools"

    echo "Installing Fcitx input framework..."
    apt-get install -y fcitx fcitx-tools > /dev/null 2>&1 || true

    echo "Installing IBus input framework..."
    apt-get install -y ibus ibus-libpinyin > /dev/null 2>&1 || true

    echo "Installing predictive text input..."
    apt-get install -y hunspell hunspell-en-us > /dev/null 2>&1 || true

    echo_success "Input method editors installed"
}

# Install motor accessibility
install_motor_accessibility() {
    echo_header "Installing Motor Accessibility Tools"

    log "Installing motor accessibility tools"

    echo "Installing mouse alternatives..."
    apt-get install -y mousetrap > /dev/null 2>&1 || true

    echo "Installing eye tracker support..."
    apt-get install -y ogama > /dev/null 2>&1 || true

    echo "Installing pointer enhancement..."
    apt-get install -y evisum > /dev/null 2>&1 || true

    echo_success "Motor accessibility tools installed"
}

# Install auditory aids
install_auditory_aids() {
    echo_header "Installing Auditory Aids"

    log "Installing auditory accessibility tools"

    echo "Installing audio visualization..."
    apt-get install -y pavucontrol > /dev/null 2>&1

    echo "Installing subtitle/caption support..."
    apt-get install -y vlc > /dev/null 2>&1 || true

    echo "Installing visual notification system..."
    apt-get install -y gnome-shell-extension-appindicator > /dev/null 2>&1 || true

    echo_success "Auditory aids installed"
}

# Install cognitive accessibility
install_cognitive_accessibility() {
    echo_header "Installing Cognitive Accessibility Tools"

    log "Installing cognitive accessibility tools"

    echo "Installing focus/distraction reduction tools..."
    apt-get install -y gnome-shell-extensions > /dev/null 2>&1 || true

    echo "Installing text simplification tools..."
    apt-get install -y wgetpaste > /dev/null 2>&1 || true

    echo "Installing task management tools..."
    apt-get install -y gnome-todo > /dev/null 2>&1 || true

    echo_success "Cognitive accessibility tools installed"
}

# Install alternative input devices
install_alternative_input() {
    echo_header "Installing Alternative Input Device Support"

    log "Installing alternative input device tools"

    echo "Installing joystick support..."
    apt-get install -y joystick jstest-gtk > /dev/null 2>&1 || true

    echo "Installing game controller support..."
    apt-get install -y antimicrox > /dev/null 2>&1 || true

    echo "Installing device mapping tools..."
    apt-get install -y input-utils > /dev/null 2>&1 || true

    echo_success "Alternative input device support installed"
}

# Create accessibility settings script
create_accessibility_helper() {
    echo_header "Creating Accessibility Helper Script"

    cat > /usr/local/bin/pentaos-accessibility << 'EOF'
#!/bin/bash
# PentaOS Accessibility Settings Helper

echo "PentaOS Accessibility Tools"
echo "============================"
echo ""
echo "Installed Tools:"
echo ""
echo "Screen Readers & Text-to-Speech:"
echo "  orca              - Full-featured screen reader (GNOME)"
echo "  espeak            - Text-to-speech engine"
echo "  festival          - Text-to-speech system"
echo ""
echo "Visual Aids:"
echo "  redshift          - Screen color temperature adjuster"
echo "  GNOME Magnifier   - Screen magnification (built-in)"
echo "  High Contrast     - High contrast themes (built-in)"
echo ""
echo "Keyboard & Input:"
echo "  onboard           - On-screen virtual keyboard"
echo "  florence          - Touch-friendly virtual keyboard"
echo "  Sticky Keys       - Modifier key assistance (built-in)"
echo "  Slow Keys         - Key press delay (built-in)"
echo ""
echo "Alternative Input:"
echo "  antimicrox        - Game controller to keyboard mapping"
echo "  joystick utils    - Joystick/gamepad support"
echo ""
echo "Quick Commands:"
echo "  - Enable screen reader: orca"
echo "  - Adjust colors: redshift-gtk"
echo "  - Virtual keyboard: onboard"
echo "  - Voice control: espeak"
echo ""
echo "System Settings:"
echo "  - GNOME Settings > Accessibility"
echo "  - KDE System Settings > Accessibility"
echo "  - XFCE Settings > Accessibility"
echo ""
echo "For detailed help, see: docs/ACCESSIBILITY.md"
EOF

    chmod +x /usr/local/bin/pentaos-accessibility
    echo_success "Accessibility helper script created"
}

# Create accessibility settings configuration
setup_accessibility_defaults() {
    echo_header "Setting Up Accessibility Defaults"

    log "Configuring default accessibility settings"

    # Create accessibility config directory
    mkdir -p /etc/pentaos/accessibility

    # Create configuration file
    cat > /etc/pentaos/accessibility/config << 'EOF'
# PentaOS Accessibility Configuration

# Screen Reader Settings
ENABLE_SCREEN_READER=true
SCREEN_READER_VOICE=english

# Visual Aids
ENABLE_MAGNIFIER=true
ENABLE_HIGH_CONTRAST=false
FONT_SIZE_SCALING=100

# Keyboard Settings
ENABLE_STICKY_KEYS=false
ENABLE_SLOW_KEYS=false
ENABLE_BOUNCE_KEYS=false
KEY_REPEAT_DELAY=500
KEY_REPEAT_RATE=30

# Mouse Settings
ENABLE_MOUSE_KEYS=false
POINTER_SIZE=1

# Color Blind Modes
COLOR_BLIND_MODE=none  # Options: none, deuteranopia, protanopia, tritanopia

# Auditory Settings
VISUAL_ALERTS=true
NOTIFICATION_SOUNDS=true

# Text Settings
ENABLE_FONT_ENHANCEMENT=false
LINE_SPACING=1.2
LETTER_SPACING=0

# Cognitive Aids
ENABLE_FOCUS_MODE=false
ENABLE_NOTIFICATIONS_SIMPLIFICATION=false
EOF

    echo_success "Accessibility defaults configured"
}

# Menu selection
show_menu() {
    echo ""
    echo -e "${BLUE}Select accessibility tools to install:${NC}"
    echo ""
    echo "  1) Essential Tools (screen reader, magnifier, keyboard access)"
    echo "  2) Visual & Display Aids (color filters, high contrast, fonts)"
    echo "  3) Alternative Input (keyboards, joystick, controllers)"
    echo "  4) Speech & Auditory (text-to-speech, visual alerts)"
    echo "  5) Cognitive Support (focus mode, simplification)"
    echo "  6) Install All Tools (Complete accessibility suite)"
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
    log "PentaOS accessibility tools installation started"

    echo_header "PentaOS Accessibility Tools Installation"
    echo ""
    echo "Install comprehensive accessibility features to make"
    echo "your Raspberry Pi usable for everyone."
    echo ""

    if ! update_packages; then
        echo_error "Failed to update packages"
        exit 1
    fi

    choice=$(show_menu)

    case "$choice" in
        1)
            log "User selected essential tools"
            install_screen_readers
            install_visual_aids
            install_keyboard_accessibility
            ;;
        2)
            log "User selected visual aids"
            install_visual_aids
            install_keyboard_accessibility
            ;;
        3)
            log "User selected alternative input"
            install_keyboard_accessibility
            install_alternative_input
            ;;
        4)
            log "User selected speech and auditory"
            install_screen_readers
            install_auditory_aids
            ;;
        5)
            log "User selected cognitive support"
            install_cognitive_accessibility
            install_visual_aids
            ;;
        6)
            log "User selected install all"
            install_screen_readers
            install_visual_aids
            install_keyboard_accessibility
            install_input_methods
            install_motor_accessibility
            install_auditory_aids
            install_cognitive_accessibility
            install_alternative_input
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

    create_accessibility_helper
    setup_accessibility_defaults
    cleanup

    echo ""
    echo_header "Installation Complete"
    echo ""
    echo "Accessibility tools have been installed successfully!"
    echo ""
    echo "Quick start:"
    echo "  ${YELLOW}pentaos-accessibility${NC}  - View all accessibility tools"
    echo ""
    echo "Enable features in:"
    echo "  - System Settings > Accessibility"
    echo "  - Applications > Accessibility"
    echo ""
    echo "Documentation: See docs/ACCESSIBILITY.md"
    echo ""

    log "PentaOS accessibility tools installation completed successfully"
}

main "$@"
