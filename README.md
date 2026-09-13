# PentaOS - Optimized Raspberry Pi Operating System

**PentaOS** is a custom-built operating system for Raspberry Pi, based on Raspberry Pi OS with enhanced features and optimizations for multi-core performance and versatility.

## Features

🚀 **Performance Optimized** - Tuned for Raspberry Pi hardware  
🌐 **Multi-Core Ready** - Optimized for modern Raspberry Pi models  
🎨 **Custom Branding** - Pentagon-themed UI, logos, and wallpapers  
🖥️ **Flexible Desktop Environments** - Choose GNOME, KDE, Pi Desktop, or Headless  
🔧 **Pre-configured Tools** - Essential development tools included  
📦 **Lightweight** - Minimal bloatware for maximum efficiency  
⚡ **Smart Setup** - Automatic detection and installation on first boot  
🎮 **Compatibility Layer** - Run Windows, x86-64, and x86 apps with Wine, Box64, and Box86  
♿ **Accessibility Suite** - Comprehensive tools for all users including screen readers, magnifiers, and alternative input devices  

## Logo

The PentaOS logo represents our five core principles:
- 🔴 **Innovation** (Red) - Pushing boundaries
- 🔵 **Connectivity** (Cyan) - Global communication
- 🟢 **Sustainability** (Green) - Long-term growth
- 🟣 **Creativity** (Purple) - Customization & flexibility
- 🟠 **Reliability** (Orange) - Rock-solid stability

[View Logo](branding/pentaos-logo.svg)

## Getting Started

### Prerequisites
- Raspberry Pi (Model 3B or newer)
- MicroSD Card (32GB or larger)
- Raspberry Pi OS base installation

### Installation

```bash
# Clone the PentaOS repository
git clone https://github.com/yourusername/pentaos.git
cd pentaos

# Build PentaOS
./build/build-pentaos.sh

# Create bootable SD card
sudo ./build/flash-sd-card.sh /dev/sdX
```

## Project Structure

```
pentaos/
├── branding/          # Logo, color palette, design guidelines
├── docs/              # Documentation and guides
├── images/            # OS images and configurations
├── src/               # Source code and customizations
├── build/             # Build scripts and tools
├── README.md          # This file
└── LICENSE            # License information
```

## System Requirements

### Minimum
- Raspberry Pi 3B or later
- 1GB RAM
- 8GB microSD card

### Recommended
- Raspberry Pi 4 or 5
- 2GB+ RAM
- 32GB+ microSD card
- USB 3.0 external storage

## Base OS Information

PentaOS is built on Raspberry Pi OS (formerly Raspbian), leveraging:
- Linux kernel optimizations
- ARM architecture support
- Official Raspberry Pi tools and firmware
- Community-driven enhancements

## Customizations

PentaOS adds the following customizations:
- Custom boot splash screen with pentagon logo
- Optimized kernel parameters
- Pre-configured development environment
- Enhanced thermal management
- Custom desktop theme
- **Intelligent Desktop Environment Selection**
  - Automatic detection of internet connectivity on first boot
  - Interactive menu to choose between GNOME, KDE, Pi Desktop, or Headless
  - Optimized installation scripts for fast setup
  - Smart configuration of display managers
- **Compatibility Layer Bundle**
  - Wine for running Windows applications
  - Box64 for x86-64 binary translation (ARM64)
  - Box86 for x86 32-bit binary translation
  - Automated installation with system detection
  - Convenient launcher scripts

## Compatibility Layer

PentaOS includes an optional compatibility layer bundle that transforms your Raspberry Pi into a multi-platform application runner:

**Supported Applications:**
- 🪟 **Windows Programs** - Via Wine compatibility layer
- 🖥️ **x86-64 Binaries** - Via Box64 dynamic translation (Pi 4/5)
- 🔧 **x86 32-bit Apps** - Via Box86 binary translation
- 🎮 **Windows Games** - DirectX 9/11 support via Wine

**Installation:**
```bash
sudo build/install-compatibility-layer.sh
```

Choose from:
- Wine only (basic Windows support)
- Box64 only (x86-64 translation)
- Box86 only (x86 32-bit translation)
- Wine + Box64 (recommended for ARM64)
- Wine + Box86 (recommended for ARMv7)
- All three components (maximum compatibility)

See [Compatibility Layer Guide](docs/COMPATIBILITY-LAYER.md) for detailed information.

## Accessibility & Inclusivity

PentaOS includes a comprehensive accessibility suite to ensure everyone can use their Raspberry Pi effectively.

**Included Tools:**
- 🔊 **Screen Readers** - Orca (GNOME), Festival, eSpeak text-to-speech
- 🔍 **Visual Aids** - Magnification, high contrast modes, color blind filters
- ⌨️ **Keyboard Access** - Sticky keys, slow keys, mouse keys, on-screen keyboards (Onboard, Florence)
- 🎮 **Alternative Input** - Joystick/gamepad support, eye tracking, controller mapping (AntiMicroX)
- 🎯 **Motor Accessibility** - Bounce key protection, pointer enhancement
- 📢 **Auditory Support** - Visual alerts, caption support
- 🧠 **Cognitive Tools** - Focus mode, notification simplification

**Installation:**
```bash
sudo build/install-accessibility-tools.sh
```

Choose from:
- Essential Tools (screen reader, magnifier, keyboard)
- Visual & Display Aids
- Alternative Input devices
- Speech & Auditory support
- Cognitive accessibility tools
- Install All (complete accessibility suite)

**Default Wallpaper:**
A beautiful PentaOS-themed wallpaper featuring the pentagon logo and 5-color scheme is set by default.

See [Accessibility Guide](docs/ACCESSIBILITY.md) for complete information and configuration options.

## Documentation

- [Branding Guide](branding/BRANDING.md)
- [Build Instructions](docs/BUILD.md)
- [Desktop Environment Setup](docs/DESKTOP-SETUP.md)
- [Compatibility Layer Guide](docs/COMPATIBILITY-LAYER.md)
- [Accessibility Guide](docs/ACCESSIBILITY.md)
- [Configuration Guide](docs/CONFIGURATION.md)
- [Contributing Guide](docs/CONTRIBUTING.md)

**Build & Setup Utilities:**
- [Compatibility Bundle Reference](build/COMPATIBILITY-BUNDLE.md) - Quick reference for Wine/Box64/Box86
- [Accessibility Tools Reference](build/install-accessibility-tools.sh) - Install screen readers, magnifiers, and alternative input

## Support & Community

For issues, feature requests, and discussions:
- GitHub Issues: [Report bugs](https://github.com/yourusername/pentaos/issues)
- GitHub Discussions: [Join community](https://github.com/yourusername/pentaos/discussions)

## License

PentaOS is provided under the same license as Raspberry Pi OS. See [LICENSE](LICENSE) file for details.

## Acknowledgments

- Raspberry Pi Foundation for the excellent OS base
- Community contributors and testers
- All open-source projects used in PentaOS

---

**Made with ❤️ for Raspberry Pi enthusiasts**

Current Version: 1.0.0-alpha  
Last Updated: 2026-09-13
