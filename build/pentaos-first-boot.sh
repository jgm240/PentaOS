#!/bin/bash

# PentaOS First Boot Setup
# This script runs automatically on first boot
# It sets up the desktop environment if internet is available

set -e

LOG_FILE="/var/log/pentaos-first-boot.log"
SETUP_LOCK="/var/lib/pentaos-setup-complete"
SETUP_SCRIPT="/usr/local/bin/pentaos-setup-desktop"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Check if setup is already complete
if [ -f "$SETUP_LOCK" ]; then
    log "Setup already completed, exiting"
    exit 0
fi

log "PentaOS first-boot setup started"

# Wait for network to be available
log "Waiting for network to be available..."
for i in {1..30}; do
    if ping -c 1 -W 1 8.8.8.8 > /dev/null 2>&1; then
        log "Network is available"
        break
    fi
    sleep 1
done

# Check if internet is available
if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
    log "Internet connection detected, launching setup wizard"

    # Give user a moment to see the system boot
    sleep 5

    # Run the setup script in interactive mode
    if [ -x "$SETUP_SCRIPT" ]; then
        log "Launching PentaOS Setup Wizard"
        # Note: In a real scenario with SSH, we'd handle this differently
        # For now, this is set up to run if accessed via console
        "$SETUP_SCRIPT"
    else
        log "Setup script not found at $SETUP_SCRIPT"
    fi
else
    log "No internet connection detected on first boot"
fi

# Mark setup as processed
mkdir -p "$(dirname "$SETUP_LOCK")"
touch "$SETUP_LOCK"
log "First-boot setup completed"

exit 0
