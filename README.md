# PentaOS - Optimized Raspberry Pi Operating System

**PentaOS** is a custom-built operating system for Raspberry Pi, based on Raspberry Pi OS with enhanced features and optimizations for multi-core performance and versatility.

## Features

🚀 **Performance Optimized** - Tuned for Raspberry Pi hardware  
🌐 **Multi-Core Ready** - Optimized for modern Raspberry Pi models  
🎨 **Custom Branding** - Pentagon-themed UI and branding  
🖥️ **Flexible Desktop Environments** - Choose GNOME, KDE, Pi Desktop, or Headless  
🔧 **Pre-configured Tools** - Essential development tools included  
📦 **Lightweight** - Minimal bloatware for maximum efficiency  
⚡ **Smart Setup** - Automatic detection and installation on first boot  

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

## Documentation

- [Branding Guide](branding/BRANDING.md)
- [Build Instructions](docs/BUILD.md)
- [Desktop Environment Setup](docs/DESKTOP-SETUP.md)
- [Configuration Guide](docs/CONFIGURATION.md)
- [Contributing Guide](docs/CONTRIBUTING.md)

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
