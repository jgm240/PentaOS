# PentaOS Desktop Environment Setup Guide

## Overview

PentaOS includes an intelligent desktop environment setup system that automatically detects internet connectivity and allows users to choose between multiple desktop environments:

- **GNOME** - Full-featured, modern desktop
- **KDE Plasma** - Highly customizable desktop
- **Raspberry Pi Desktop (XFCE)** - Lightweight, optimized for Pi
- **Headless** - Command-line only

## Automatic Setup (First Boot)

### How It Works

On first boot, if an internet connection is detected, PentaOS will:

1. Wait for network to become available (up to 30 seconds)
2. Check for internet connectivity (pings multiple DNS servers)
3. Launch an interactive setup wizard if connected
4. Display system requirements for each desktop option
5. Install the chosen environment
6. Configure the display manager
7. Mark setup as complete (won't run again)

### System Requirements

| Desktop | Min RAM | Recommended | Disk Space | Installation Time |
|---------|---------|-------------|------------|-------------------|
| GNOME | 2GB | 4GB+ | 3-4GB | 20-30 min |
| KDE Plasma | 2GB | 4GB+ | 3-4GB | 25-40 min |
| Pi Desktop (XFCE) | 512MB | 1GB+ | 1-2GB | 10-20 min |
| Headless | 256MB | 512MB+ | 500MB | N/A |

## Manual Setup

### Running the Setup Script

If the automatic setup doesn't run or you want to change your desktop environment later:

```bash
# Method 1: Using the setup script directly
sudo build/setup-desktop.sh

# Method 2: From the system install location
sudo /usr/local/bin/pentaos-setup-desktop
```

### Interactive Menu

The setup script presents a user-friendly menu:

```
Choose Desktop Environment:

  1) GNOME - Feature-rich, modern desktop
     Memory: Higher | Speed: Good | Features: Extensive

  2) KDE Plasma - Customizable, powerful desktop
     Memory: High | Speed: Good | Features: Extensive

  3) Raspberry Pi Desktop - Lightweight, optimized
     Memory: Low | Speed: Excellent | Features: Basic

  4) None - Command-line only (headless)
     Memory: Minimal | Speed: N/A | Features: None

Enter your choice (1-4):
```

### Step-by-Step Guide

1. **Check Internet Connection**
   - The script verifies internet availability
   - If no connection, installation is skipped

2. **Review System Information**
   ```
   System Information:
     Raspberry Pi Model: ...
     Available RAM: 2048MB
     Free Disk Space: 15.5GB
   ```

3. **Choose Your Desktop**
   - Enter 1, 2, 3, or 4 based on preference

4. **Installation**
   - Package lists are updated
   - Desktop environment is installed
   - Display manager is configured
   - Unused packages are cleaned up

5. **Reboot**
   ```bash
   sudo reboot
   ```

## Desktop Environment Comparison

### GNOME

**Pros:**
- Modern, elegant interface
- Intuitive user experience
- Excellent application integration
- Regular updates and improvements

**Cons:**
- High memory usage (2GB+ recommended)
- Longer boot time
- More system resources required

**Best For:**
- Users wanting a modern desktop
- Pi 4/5 with 4GB+ RAM
- Multitasking workflows

**Installation:**
```bash
sudo build/setup-desktop.sh
# Select option 1
```

### KDE Plasma

**Pros:**
- Highly customizable
- Powerful features
- Fast and responsive
- Excellent theming support

**Cons:**
- Higher memory usage (2GB+ recommended)
- Can take 30+ minutes to install
- More complex than Pi Desktop

**Best For:**
- Power users
- Customization enthusiasts
- Pi 4/5 with 4GB+ RAM

**Installation:**
```bash
sudo build/setup-desktop.sh
# Select option 2
```

### Raspberry Pi Desktop (XFCE)

**Pros:**
- Lightweight and fast
- Optimized for Raspberry Pi
- Minimal resource usage
- Quick installation

**Cons:**
- Basic features
- Simpler interface
- Limited customization

**Best For:**
- Resource-constrained systems
- Pi 3B/3B+ users
- Lightweight workflows

**Installation:**
```bash
sudo build/setup-desktop.sh
# Select option 3
```

### Headless (Command-line)

**Pros:**
- Minimal resource usage
- Fastest performance
- Perfect for servers
- Small disk footprint

**Cons:**
- No graphical interface
- Requires command-line knowledge
- Limited for visual tasks

**Best For:**
- Server deployments
- Headless applications
- Development environments
- IoT projects

**Installation:**
```bash
sudo build/setup-desktop.sh
# Select option 4
```

## Changing Desktop Environments

### Switch Between Desktops

To switch from one desktop to another:

```bash
# Run the setup script again
sudo build/setup-desktop.sh

# Choose a different desktop environment
# The new environment will be installed alongside the old one
```

### Remove a Desktop Environment

To uninstall a desktop environment:

```bash
# GNOME
sudo apt-get remove -y gnome-desktop-environment gdm3

# KDE Plasma
sudo apt-get remove -y kde-plasma-desktop sddm

# Raspberry Pi Desktop
sudo apt-get remove -y raspberrypi-ui-mods lightdm

# Clean up
sudo apt-get autoremove -y
sudo apt-get clean
```

### Set Default Desktop at Boot

The setup script automatically configures the display manager. To manually set the default:

```bash
# For GNOME
sudo update-alternatives --set x-session-manager /usr/bin/gnome-session

# For KDE
sudo update-alternatives --set x-session-manager /usr/bin/startplasma-x11

# For XFCE (Pi Desktop)
sudo update-alternatives --set x-session-manager /usr/bin/xfce4-session
```

## Troubleshooting

### Setup Script Doesn't Start on First Boot

**Problem:** The interactive setup wizard doesn't appear

**Solutions:**
1. Check internet connection
   ```bash
   ping 8.8.8.8
   ```

2. Run manually after boot
   ```bash
   sudo build/setup-desktop.sh
   ```

3. Check logs
   ```bash
   sudo tail -f /var/log/pentaos-first-boot.log
   ```

### Installation Fails Due to Low Disk Space

**Problem:** "No space left on device" error

**Solution:**
1. Check available space
   ```bash
   df -h
   ```

2. Clean up disk space
   ```bash
   sudo apt-get clean
   sudo apt-get autoclean
   # Remove old log files
   sudo rm -rf /var/log/*.1 /var/log/*.gz
   ```

3. Retry installation
   ```bash
   sudo build/setup-desktop.sh
   ```

### Installation Fails Due to Network Issues

**Problem:** Package download fails mid-installation

**Solutions:**
1. Check network status
   ```bash
   ping -c 3 8.8.8.8
   iwconfig wlan0  # For WiFi info
   ```

2. Update package lists
   ```bash
   sudo apt-get update
   ```

3. Retry
   ```bash
   sudo build/setup-desktop.sh
   ```

### Desktop Doesn't Start After Installation

**Problem:** Black screen after login or crashes

**Solutions:**
1. Check if X server is running
   ```bash
   ps aux | grep X
   ```

2. Check error logs
   ```bash
   cat ~/.xsession-errors
   journalctl -xe
   ```

3. Reinstall the desktop
   ```bash
   sudo build/setup-desktop.sh
   ```

4. Try a different desktop environment
   ```bash
   # Remove current
   sudo apt-get remove -y <package-name>
   # Install different one
   sudo build/setup-desktop.sh
   ```

### High Memory Usage

**Problem:** System feels slow or unresponsive

**Solutions:**
1. Check RAM usage
   ```bash
   free -h
   top
   ```

2. Consider switching to lighter desktop
   ```bash
   sudo build/setup-desktop.sh
   # Choose Raspberry Pi Desktop or Headless
   ```

3. Disable unnecessary services
   ```bash
   sudo systemctl disable bluetooth
   sudo systemctl disable cups
   ```

### Keyboard/Mouse Not Working in GUI

**Problem:** Input devices not responding

**Solutions:**
1. Check device detection
   ```bash
   lsusb
   ls /dev/input/
   ```

2. Reinstall input drivers
   ```bash
   sudo apt-get install --reinstall xserver-xorg-input-all
   ```

3. Try different desktop environment

## Logging and Monitoring

### Setup Logs

Setup progress is logged to:
```bash
/var/log/pentaos-setup.log
```

View logs:
```bash
sudo tail -f /var/log/pentaos-setup.log
```

### First Boot Logs

First boot setup logs:
```bash
/var/log/pentaos-first-boot.log
```

### System Logs

Check system journal:
```bash
journalctl -xe
journalctl -u pentaos-first-boot.service
```

## Advanced Configuration

### Automating Setup for Multiple Devices

Create a script to automate installation:

```bash
#!/bin/bash
# auto-setup.sh - Automate desktop setup

DESKTOP_CHOICE=${1:-3}  # Default to Pi Desktop

# Run setup with piping input
echo "$DESKTOP_CHOICE" | sudo build/setup-desktop.sh
```

### Pre-Installation Package Verification

Check what will be installed:

```bash
# GNOME
apt-cache show gnome-desktop-environment | grep -i "installed-size"

# KDE Plasma  
apt-cache show kde-plasma-desktop | grep -i "installed-size"

# Pi Desktop
apt-cache show raspberrypi-ui-mods | grep -i "installed-size"
```

### Monitoring Installation Progress

Track installation in real-time:

```bash
# In one terminal
sudo tail -f /var/log/pentaos-setup.log

# In another, check disk usage
watch -n 1 'df -h / | tail -1'
```

## FAQ

**Q: Can I have multiple desktop environments installed?**
A: Yes! Install multiple environments and choose at boot time. Use the display manager to switch between them.

**Q: Does installation require internet for every boot?**
A: No, only for the initial setup. After installation, the desktop works offline.

**Q: What if I choose headless by mistake?**
A: Just run the setup script again and choose a GUI desktop environment.

**Q: Can I uninstall everything and go headless later?**
A: Yes, you can remove all desktop environments and operate in headless mode.

**Q: How much does each desktop affect performance?**
A: GNOME/KDE add ~500MB RAM overhead. Pi Desktop adds ~200MB. Headless has minimal overhead.

---

Last Updated: 2026-09-13
