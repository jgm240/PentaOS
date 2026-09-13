# PentaOS Compatibility Layer Guide

## Overview

PentaOS includes a powerful compatibility layer that allows you to run:
- **Windows applications** via Wine
- **x86-64 binaries** via Box64 (ARM64 only)
- **x86 32-bit binaries** via Box86 (ARMv7/ARMv6)

This enables your Raspberry Pi to run software originally designed for Windows and x86 systems.

## Components

### Wine
Wine is a compatibility layer that allows you to run Windows applications on Linux systems.

**Features:**
- Run .exe files natively
- Support for DirectX, OpenGL
- Windows API compatibility
- Winetricks for installing Windows libraries

**Best For:**
- Windows desktop applications
- Games with Windows versions
- Business software

### Box64
Box64 is a dynamic binary translator that converts x86-64 code to ARM64 in real-time.

**Features:**
- JIT compilation for performance
- Dynarec (dynamic recompilation)
- Full x86-64 instruction set support
- Transparent to applications

**Requirements:**
- Raspberry Pi 4/5 (ARM64 architecture)
- 2GB+ RAM recommended
- 64-bit OS

### Box86
Box86 is a dynamic binary translator for x86 (32-bit) to ARM systems.

**Features:**
- x86 32-bit binary support
- JIT compilation
- Works on ARMv7/ARMv6
- Compatible with Box64 on ARM64

**Requirements:**
- ARMv7 or ARMv6 compatible Raspberry Pi
- 1GB+ RAM recommended

## Installation

### Quick Install

For automated installation with menu selection:

```bash
sudo build/install-compatibility-layer.sh
```

The script will:
1. Check your system architecture
2. Verify available resources
3. Present a menu of options
4. Install selected components
5. Create convenient launcher scripts
6. Clean up temporary files

### Manual Installation

#### Install Wine Only

```bash
sudo apt-get update
sudo apt-get install -y wine wine32 wine64 winetricks
```

#### Build Box64 from Source

```bash
# Clone repository
git clone https://github.com/ptitSeb/box64.git /opt/box64
cd /opt/box64

# Build
mkdir build && cd build
cmake -DBOX64_ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
make -j$(nproc)
sudo make install
```

#### Build Box86 from Source

```bash
# Clone repository
git clone https://github.com/ptitSeb/box86.git /opt/box86
cd /opt/box86

# Build
mkdir build && cd build
cmake -DBOX86_DYNAREC=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
make -j$(nproc)
sudo make install
```

## Usage

### Running Wine Applications

```bash
# Run a Windows executable
wine program.exe

# Run with arguments
wine program.exe --option value

# Use Winetricks to install components
winetricks dotnet48          # Install .NET Framework
winetricks vcrun2019         # Install Visual C++ Runtime
winetricks d3dx9             # Install DirectX 9
winetricks corefonts         # Install Windows fonts
```

### Running x86-64 Applications with Box64

```bash
# Run an x86-64 binary
box64 program

# With environment variables
BOX64_DYNAREC=1 box64 program

# Using convenience launcher
run-x86-64 program
```

### Running x86 32-bit Applications with Box86

```bash
# Run an x86 32-bit binary
box86 program

# With environment variables
BOX86_DYNAREC=1 box86 program

# Using convenience launcher
run-x86-32 program
```

### Convenience Launchers

The installation creates three launcher scripts for easy access:

```bash
# Run x86-64 applications
run-x86-64 /path/to/app

# Run x86 32-bit applications
run-x86-32 /path/to/app

# Run Windows applications
run-windows app.exe
```

## Wine Configuration

### Wine Prefixes

Wine uses "prefixes" (virtual Windows environments):

```bash
# Default prefix
~/.wine

# Create custom prefix
WINEPREFIX=~/.wine-game wine program.exe

# List installed packages
wine uninstaller
```

### Wine Registry

Edit Wine registry settings:

```bash
# Open registry editor
regedit

# Or edit directly
wine reg add "HKEY_LOCAL_MACHINE\Software\..." /v Setting /d Value
```

### Performance Settings

```bash
# Disable CSMT (for older games)
winetricks -q csmtoff

# Set Windows version
WINEARCH=win32 wine cmd.exe /c "ver"

# CPU affinity (use specific cores)
taskset -c 0-3 wine program.exe
```

## Performance Optimization

### Box64/Box86 Optimization

```bash
# Enable dynamic recompilation (faster)
export BOX64_DYNAREC=1
export BOX86_DYNAREC=1

# Enable JIT with more cache
export BOX64_DYNAREC_SAFEFUNC=1
export BOX86_DYNAREC_SAFEFUNC=1

# Disable graphics if not needed
export BOX64_NOGRAB=1
```

### Wine Optimization

```bash
# Use DXVK for better graphics
winetricks dxvk

# Set CSMT thread count
CSMT=enabled wine program.exe

# Virtual Desktop mode
export WINEPREFIX=~/.wine
wineboot -e /c "winedevices"
```

## Troubleshooting

### Wine Applications Crash

**Problem:** Application crashes on startup

**Solutions:**
1. Check dependencies
   ```bash
   winetricks -q vcrun2019
   winetricks -q d3dx9
   ```

2. Try different Windows version
   ```bash
   winetricks winver win7
   ```

3. Check logs
   ```bash
   WINEDEBUG=+all wine app.exe 2>&1 | head -50
   ```

### Box64 Performance Issues

**Problem:** Application runs slowly

**Solutions:**
1. Enable dynarec
   ```bash
   export BOX64_DYNAREC=1
   box64 app
   ```

2. Check CPU usage
   ```bash
   top -p $(pidof box64)
   ```

3. Increase swap
   ```bash
   free -h
   # Adjust if needed
   ```

### Missing Libraries

**Problem:** "Cannot find library" error

**Solutions:**
```bash
# For Wine
winetricks -q vcrun2019 dotnet48

# Check installed packages
wine uninstaller

# Install specific library
winetricks -q d3dx11
```

### Graphics Issues

**Problem:** Black screen or graphics glitches

**Solutions:**
1. Use DXVK (faster than OpenGL)
   ```bash
   winetricks dxvk
   ```

2. Try software rendering
   ```bash
   LIBGL_ALWAYS_INDIRECT=1 wine app.exe
   ```

3. Update GPU drivers
   ```bash
   sudo apt-get update
   sudo apt-get install -y mesa-utils
   ```

## System Requirements

### For Wine

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| Storage | 1GB | 5GB+ |
| RAM | 512MB | 2GB+ |
| CPU | Any ARM | Modern multi-core |
| Pi Model | 2B | 4B/5 |

### For Box64

| Component | Requirement |
|-----------|------------|
| Architecture | ARM64 only |
| Storage | 2GB |
| RAM | 2GB+ |
| Pi Model | 4B/5 only |

### For Box86

| Component | Requirement |
|-----------|------------|
| Architecture | ARMv7/ARMv6 |
| Storage | 1.5GB |
| RAM | 1GB+ |
| Pi Model | 3B+ and later |

## Advanced Usage

### Running Windows Games

```bash
# Install game dependencies
cd ~/Games
winetricks -q vcrun2019 d3dx11 d3d9

# Run game
wine game.exe

# Run with debug info
WINEDEBUG=fixme-all wine game.exe
```

### Building x86 Binaries for Box64

```bash
# Install cross-compiler
sudo apt-get install -y gcc-x86-64-linux-gnu

# Compile for x86-64
gcc -o app app.c

# Run with Box64
box64 ./app
```

### Container-Based Isolation

```bash
# Run Wine in isolated environment
WINEPREFIX=~/.wine-isolated wine program.exe

# Or use bwrap for sandboxing (if available)
bwrap --bind /root ~/.wine --tmpfs /tmp wine program.exe
```

## Common Applications

### Tested and Working

- **Games:** Windows games with DirectX 9/11 support
- **Office:** Some versions of Office work with dependencies
- **Utilities:** Notepad++, 7-Zip, etc.
- **Media:** VLC, FFmpeg built for Windows

### Known Issues

- Some games require specific GPU support
- High-performance games may be slow
- Copy protection (DRM) may not work
- Some hardware-specific software incompatible

## Performance Expectations

### Realistic Benchmarks

| Task | Performance | Notes |
|------|-------------|-------|
| Simple games | 30-60 FPS | Depends on complexity |
| Complex games | 10-30 FPS | Reduced graphics help |
| Office apps | Native | Minimal overhead |
| Utilities | Native | Fast, lightweight |

### Optimization Tips

1. **Reduce resolution** - Lower game resolution for better FPS
2. **Disable fancy graphics** - Turn off effects/shadows
3. **Use lower detail levels** - Reduce texture quality
4. **Enable VSync** - Smoother experience
5. **Close background apps** - More resources for your app

## Uninstalling

### Remove Wine

```bash
sudo apt-get remove -y wine winetricks
rm -rf ~/.wine
```

### Remove Box64

```bash
rm -f /usr/local/bin/box64
rm -rf /opt/box64
```

### Remove Box86

```bash
rm -f /usr/local/bin/box86
rm -rf /opt/box86
```

### Remove All

```bash
sudo build/install-compatibility-layer.sh  # Run script
# Then select "Cancel" or remove each component manually
```

## Resources

- **Wine Project:** https://www.winehq.org/
- **Box64:** https://github.com/ptitSeb/box64
- **Box86:** https://github.com/ptitSeb/box86
- **Winetricks:** https://github.com/Winetricks/winetricks
- **AppDB:** https://appdb.winehq.org/

## FAQ

**Q: Will this run all Windows software?**
A: Not all. Compatibility depends on what the software needs (e.g., specific GPU support, modern graphics).

**Q: Is it faster than dual-boot?**
A: Generally, Wine/Box64/Box86 have minimal overhead compared to native execution, though compatibility varies.

**Q: Can I run Visual Studio or professional software?**
A: Some tools work; others require specific Windows components. Test first.

**Q: How much disk space do I need?**
A: 5-10GB recommended for Wine plus applications.

**Q: Is it safe to run untrusted Windows executables?**
A: Wine provides some isolation, but it's not a sandbox. Be cautious with untrusted software.

**Q: Can I run both 32-bit and 64-bit Windows apps?**
A: Yes, if you install both wine32 and wine64.

---

Last Updated: 2026-09-13
