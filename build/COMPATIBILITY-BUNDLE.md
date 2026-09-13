# PentaOS Compatibility Layer Bundle

## Overview

The PentaOS Compatibility Layer Bundle provides seamless integration of three powerful compatibility tools:

1. **Wine** - Windows application compatibility
2. **Box64** - x86-64 to ARM64 binary translation
3. **Box86** - x86 32-bit to ARM binary translation

This bundle transforms your Raspberry Pi into a versatile platform capable of running software from the Windows and x86 ecosystems.

## Quick Start

### Installation

```bash
# Run the automated installer
sudo build/install-compatibility-layer.sh

# Follow the interactive menu
# Choose which components to install
# Wait for installation to complete
```

### First Use

```bash
# Run a Windows application
wine notepad.exe

# Run an x86-64 application
box64 some-x86-app

# Run an x86 32-bit application
box86 some-x86-app-32bit
```

## What's Included

### Wine (Windows Compatibility)
- Full Windows API layer
- DirectX 9, 10, 11 support
- OpenGL graphics support
- 3000+ tested applications
- Winetricks for easy component installation

### Box64 (ARM64 x86-64 Translation)
- Dynamic binary translation
- JIT (Just-In-Time) compilation
- High performance translation
- Transparent to applications
- Full x86-64 instruction support

### Box86 (ARMv7/ARMv6 x86 Translation)
- 32-bit x86 binary support
- ARMv7/ARMv6 compatible
- Dynarec optimization
- Lightweight execution

## Installation Options

### Option 1: Wine Only
Minimal install for basic Windows application support.
- **Size:** ~500MB
- **Time:** 2-3 minutes
- **Best for:** Desktop applications, productivity software

### Option 2: Box64 Only
Just x86-64 binary translation.
- **Size:** ~300MB (built from source)
- **Time:** 10-15 minutes
- **Requires:** ARM64 architecture
- **Best for:** x86-64 specific applications

### Option 3: Box86 Only
Just x86 32-bit binary translation.
- **Size:** ~300MB (built from source)
- **Time:** 10-15 minutes
- **Best for:** Legacy x86 applications

### Option 4: Wine + Box64 (ARM64 Recommended)
Complete compatibility suite for ARM64 systems.
- **Size:** ~800MB
- **Time:** 15-20 minutes
- **Best for:** Maximum compatibility on Raspberry Pi 4/5

### Option 5: Wine + Box86 (ARMv7 Recommended)
Complete compatibility suite for ARMv7 systems.
- **Size:** ~800MB
- **Time:** 15-20 minutes
- **Best for:** Maximum compatibility on Raspberry Pi 3B+

### Option 6: Install All
All three components together.
- **Size:** ~1.2GB
- **Time:** 20-30 minutes
- **Best for:** Testing and maximum flexibility

## System Requirements

### Minimum
- Raspberry Pi 3B or later
- 1GB RAM
- 2GB free disk space
- ARM64 or ARMv7 architecture

### Recommended
- Raspberry Pi 4 or 5
- 2GB+ RAM
- 5GB+ free disk space
- 64-bit OS (Raspberry Pi OS 64-bit)

## Architecture Compatibility

| Component | Pi 3B+ | Pi 4B | Pi 5 | Architecture |
|-----------|--------|-------|------|-------------|
| Wine | ✓ | ✓ | ✓ | All ARM |
| Box64 | ✗ | ✓ | ✓ | ARM64 only |
| Box86 | ✓ | ✓ | ✓ | ARMv7/ARMv6 |

## Performance Characteristics

### Wine
- **Overhead:** Minimal (5-10%)
- **Compatibility:** 80%+ of Windows software
- **Speed:** Near-native for CPU-bound tasks

### Box64
- **Overhead:** 10-30% (translation overhead)
- **Compatibility:** High for pure x86-64 binaries
- **Speed:** Depends on dynarec hit rate

### Box86
- **Overhead:** 15-40% (translation overhead)
- **Compatibility:** Moderate (less mature than Box64)
- **Speed:** Better on modern ARM CPUs

## Typical Use Cases

### Gaming
```bash
# Windows games
wine game.exe

# x86-64 games
box64 game-linux-x86

# Classic DOS/older games
wine dosbox.exe
```

### Productivity
```bash
# Office applications
wine winword.exe

# Development tools
wine codeblocks.exe

# Media tools
wine audacity.exe
```

### Utilities & Tools
```bash
# Compression
wine 7zinstall.exe

# System utilities
wine everything.exe

# File managers
wine total-commander.exe
```

### Development
```bash
# Build x86 apps for testing
box64 ./my-x86-64-binary

# Test Windows builds
wine ./my-app.exe

# Cross-compilation
gcc -m32 -o app app.c
box86 ./app
```

## Installation Time Estimates

| Component | Build Time | Install Time | Total |
|-----------|-----------|--------------|-------|
| Wine | N/A | 2-3 min | 2-3 min |
| Box64 | 8-12 min | 2-3 min | 10-15 min |
| Box86 | 8-12 min | 2-3 min | 10-15 min |
| All 3 | 16-24 min | 6-9 min | 22-33 min |

Build time depends on:
- CPU cores available (uses all)
- System load
- Disk speed
- RAM available

## Disk Space Usage

| Component | Installed Size |
|-----------|----------------|
| Wine | ~500MB |
| Box64 | ~200MB (binary + libs) |
| Box86 | ~200MB (binary + libs) |
| Total | ~900MB |

Plus application space and Wine prefixes (grows with usage).

## Verification

### Test Installation

```bash
# Check Wine
wine --version

# Check Box64
box64 --version || echo "Box64 not installed"

# Check Box86
box86 --version || echo "Box86 not installed"

# Test a simple application
wine calc.exe
```

## Troubleshooting

### Installation Fails
```bash
# Check logs
cat /var/log/pentaos-compatibility-install.log

# Check disk space
df -h

# Check internet connection
ping 8.8.8.8
```

### Application Won't Run
```bash
# Check if binary exists
file /path/to/app.exe

# Check dependencies
ldd /path/to/app

# Try with debug output
WINEDEBUG=+all wine app.exe 2>&1 | head -50
```

### Poor Performance
```bash
# Enable dynarec
export BOX64_DYNAREC=1

# Check CPU usage
top -p $(pidof box64)

# Monitor memory
free -h
```

## Uninstallation

```bash
# Remove Wine
sudo apt-get remove -y wine winetricks
rm -rf ~/.wine

# Remove Box64
rm -rf /opt/box64 /usr/local/bin/box64

# Remove Box86
rm -rf /opt/box86 /usr/local/bin/box86

# Remove launcher scripts
rm -f /usr/local/bin/run-*
```

## Advanced Configuration

### Custom Wine Prefixes
```bash
# Create isolated environment for each app
WINEPREFIX=~/.wine-game1 wine game1.exe
WINEPREFIX=~/.wine-game2 wine game2.exe
```

### Box64 Environment Variables
```bash
export BOX64_DYNAREC=1              # Enable JIT
export BOX64_NOGRAB=1               # Disable mouse grab
export BOX64_LOG=1                  # Enable logging
export BOX64_LIBGL=libGL.so.1        # Force OpenGL lib
```

### Box86 Environment Variables
```bash
export BOX86_DYNAREC=1              # Enable JIT
export BOX86_DYNAREC_SAFEFUNC=1     # Safer but slower
export BOX86_LOG=1                  # Enable logging
```

## Support & Resources

### Documentation
- Full guide: `docs/COMPATIBILITY-LAYER.md`
- Installation script help: `sudo build/install-compatibility-layer.sh --help`

### External Resources
- Wine: https://www.winehq.org/
- Box64: https://github.com/ptitSeb/box64
- Box86: https://github.com/ptitSeb/box86
- AppDB: https://appdb.winehq.org/

## FAQ

**Q: Which should I install first?**
A: Wine is the most stable and useful. Box64/Box86 are supplementary.

**Q: Can I install them one at a time?**
A: Yes, they're independent. Run the installer multiple times if needed.

**Q: Will this slow down my Raspberry Pi?**
A: Only when running Wine/Box64/Box86 apps. Normal system performance is unaffected.

**Q: Can I use all three together?**
A: Yes, they don't conflict. Wine is for Windows apps; Box64/Box86 are for native x86 binaries.

**Q: Which Raspberry Pi is best for this?**
A: Pi 4B or 5 (ARM64) for best performance with all three components.

---

Last Updated: 2026-09-13
