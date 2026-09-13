# PentaOS Configuration Guide

## System Configuration

### Hostname

To change the device hostname from `raspberrypi` to something custom:

```bash
sudo raspi-config
# Navigate to: System Options → Hostname
```

Or manually:

```bash
sudo nano /etc/hostname
# Replace "raspberrypi" with your desired hostname

sudo nano /etc/hosts
# Update localhost entry to use new hostname
```

### Locale and Timezone

```bash
sudo raspi-config
# Navigate to: Localization Options → Timezone/Locale

# Or manually:
sudo timedatectl set-timezone America/New_York
sudo locale-gen en_US.UTF-8
```

### Network Configuration

#### WiFi Setup

```bash
sudo raspi-config
# Navigate to: System Options → Wireless LAN
# Enter SSID and password

# Or manually edit:
sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
```

#### Static IP Address

```bash
sudo nano /etc/dhcpcd.conf

# Add at the end:
interface eth0
static ip_address=192.168.1.100/24
static routers=192.168.1.1
static domain_name_servers=8.8.8.8

interface wlan0
static ip_address=192.168.1.101/24
static routers=192.168.1.1
static domain_name_servers=8.8.8.8

# Reboot to apply
sudo reboot
```

## Performance Optimization

### CPU Frequency Scaling

```bash
# Check current frequency
watch -n1 'cat /proc/cpuinfo | grep MHz'

# View thermal throttling
vcgencmd measure_clock arm
vcgencmd measure_volts core
```

### GPU Memory Allocation

```bash
sudo raspi-config
# Navigate to: Performance Options → GPU Memory
# Recommended: 128MB for headless, 256MB for desktop

# Or manually:
sudo nano /boot/firmware/config.txt
# Find: gpu_mem=
```

### Overclock Settings (Advanced)

```bash
sudo nano /boot/firmware/config.txt

# Add to [pi4] section (Raspberry Pi 4 only):
over_voltage=2
arm_freq=2000

# Reboot to apply
sudo reboot
```

⚠️ **Warning:** Overclocking may void warranty and reduce device lifespan.

## Storage Management

### Expand Filesystem

Automatically expands root partition on first boot. To manually expand:

```bash
sudo raspi-config
# Navigate to: Advanced Options → Expand Filesystem

# Or use parted:
sudo parted /dev/mmcblk0 print
sudo parted -s /dev/mmcblk0 resizepart 2 100%
sudo resize2fs /dev/mmcblk0p2
```

### Monitor Disk Usage

```bash
# View disk space
df -h

# View directory sizes
du -sh ~/
du -sh /home/*

# Find large files
find ~ -type f -size +100M -exec ls -lh {} \;
```

### Enable USB Boot (Pi 4/5)

```bash
# Update bootloader
sudo apt update
sudo apt install rpi-eeprom

# Set boot order
sudo rpi-eeprom-config --edit
# Uncomment: BOOT_ORDER=0x1  # Try USB first, then SD
```

## Security Configuration

### SSH Hardening

```bash
# Generate new SSH keys
sudo ssh-keygen -A -N "" -t rsa -b 4096

# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Recommended changes:
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
X11Forwarding no

# Restart SSH
sudo systemctl restart ssh
```

### Firewall Setup

```bash
# Install ufw firewall
sudo apt install ufw

# Enable firewall
sudo ufw enable

# Allow SSH
sudo ufw allow 22/tcp

# Allow specific ports
sudo ufw allow 80/tcp  # HTTP
sudo ufw allow 443/tcp # HTTPS

# View status
sudo ufw status
```

### User Management

```bash
# Create new user
sudo adduser newuser

# Add to sudo group
sudo usermod -aG sudo newuser

# Disable pi user (after creating admin account)
sudo passwd -l pi

# Delete pi user (careful!)
sudo userdel -r pi
```

## Software Updates

### System Updates

```bash
# Update package lists
sudo apt update

# Upgrade packages
sudo apt upgrade

# Full upgrade (may upgrade kernel)
sudo apt full-upgrade

# Auto-remove unused packages
sudo apt autoremove

# Clean package cache
sudo apt clean
```

### Enable Unattended Upgrades

```bash
# Install unattended-upgrades
sudo apt install unattended-upgrades

# Configure
sudo dpkg-reconfigure -plow unattended-upgrades

# Check status
sudo systemctl status unattended-upgrades
```

## Interface Configuration

### Display Configuration

```bash
sudo raspi-config
# Performance Options → Display → Set preferred resolution

# Or manually:
sudo nano /boot/firmware/config.txt
```

### Desktop Environment

```bash
# Start graphical desktop
startx

# Use VNC for remote access
sudo raspi-config
# Interfacing Options → VNC → Enable
```

## Development Environment

### Install Programming Tools

```bash
# Python
sudo apt install python3 python3-pip python3-dev

# Node.js
curl -sL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install nodejs

# Git
sudo apt install git

# Build essentials
sudo apt install build-essential
```

### Configure Python Virtual Environment

```bash
# Create virtual environment
python3 -m venv ~/venv

# Activate
source ~/venv/bin/activate

# Deactivate
deactivate
```

## System Services

### Enable/Disable Services

```bash
# View running services
sudo systemctl list-units --type=service

# Enable service at startup
sudo systemctl enable <service-name>

# Start service now
sudo systemctl start <service-name>

# Stop service
sudo systemctl stop <service-name>

# Check service status
sudo systemctl status <service-name>
```

## Hardware Configuration

### GPIO Control

```bash
# Install GPIO library
sudo apt install python3-gpiozero

# Test GPIO
python3
>>> from gpiozero import LED
>>> led = LED(17)
>>> led.on()
>>> led.off()
```

### I2C/SPI Enable

```bash
sudo raspi-config
# Interfacing Options → I2C → Enable
# Interfacing Options → SPI → Enable

# Check devices
i2cdetect -y 1
ls /dev/spi*
```

## Monitoring and Logging

### System Logs

```bash
# View system logs
journalctl -xe

# View specific service logs
journalctl -u ssh -n 50

# Real-time monitoring
journalctl -f
```

### System Monitoring

```bash
# Install monitoring tools
sudo apt install htop iotop vnstat

# Monitor CPU/Memory
htop

# Monitor I/O
iotop

# Monitor network
vnstat -i wlan0
```

## Backup and Recovery

### Create System Backup

```bash
# Backup to file
sudo dd if=/dev/mmcblk0 of=pentaos-backup.img status=progress

# Compress backup
gzip pentaos-backup.img

# Restore from backup
sudo dd if=pentaos-backup.img.gz of=/dev/mmcblk0 status=progress
```

---

Last Updated: 2026-09-13
