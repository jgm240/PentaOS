# PentaOS Accessibility Guide

## Overview

PentaOS includes comprehensive accessibility features and tools to ensure everyone can use their Raspberry Pi effectively, regardless of physical or cognitive abilities.

**Our Commitment:** Making technology inclusive for all users.

## Features & Categories

### Visual Accessibility
- Screen readers
- Screen magnification
- High contrast modes
- Large font support
- Color blind filters

### Motor Accessibility
- Sticky keys
- Slow keys
- Bounce key protection
- Mouse/keyboard alternatives
- On-screen keyboards
- Joystick/controller support

### Hearing Accessibility
- Visual alerts and notifications
- Text captions
- Screen reader audio output
- Volume control

### Cognitive Accessibility
- Focus mode
- Simplified notifications
- Clear UI options
- Text simplification

## Installation

### Quick Install

For automated installation of all accessibility tools:

```bash
sudo build/install-accessibility-tools.sh
```

Choose from installation options:
1. Essential Tools (screen reader, magnifier, keyboard)
2. Visual & Display Aids
3. Alternative Input (keyboards, joystick, controllers)
4. Speech & Auditory
5. Cognitive Support
6. Install All Tools
7. Cancel

### Manual Installation

#### Install Individual Components

**Screen Readers:**
```bash
sudo apt-get install -y orca espeak festival
```

**Magnification:**
```bash
sudo apt-get install -y gnome-shell-extensions-magnifier
```

**Virtual Keyboards:**
```bash
sudo apt-get install -y onboard florence
```

**Alternative Input:**
```bash
sudo apt-get install -y antimicrox joystick jstest-gtk
```

**Text-to-Speech:**
```bash
sudo apt-get install -y espeak espeak-ng
```

**Color Filters:**
```bash
sudo apt-get install -y redshift-gtk
```

## Accessibility Tools

### Screen Readers

#### Orca (GNOME)
Full-featured screen reader for GNOME desktop.

**Enable:**
- Settings > Accessibility > Screen Reader
- Or press: `Alt + Super + S`

**Usage:**
```bash
orca --help
```

**Features:**
- Full desktop navigation
- Application-specific support
- Web page reading
- Custom keyboard shortcuts

#### Festival & eSpeak
Text-to-speech engines.

**Usage:**
```bash
# Use Festival
echo "Hello world" | festival --tts

# Use eSpeak
espeak "Hello world"
```

### Visual Aids

#### Screen Magnification
Zoom in on screen content.

**GNOME:**
- Settings > Accessibility > Zoom
- Scroll with Ctrl+scroll wheel
- Keyboard: Super + =

**Shortcut Keys:**
```bash
Ctrl + Plus       # Zoom in
Ctrl + Minus      # Zoom out
Ctrl + 0          # Reset zoom
```

#### High Contrast Mode
Increase visual clarity.

**Enable:**
- Settings > Appearance > High Contrast
- Improves readability
- Reduces eye strain

**Benefits:**
- Easier to read text
- Better visibility of UI elements
- Reduced glare on bright screens

#### Color Blind Filters
Adjust colors for different types of color blindness.

**Available Modes:**
- Normal (no filter)
- Deuteranopia (red-green)
- Protanopia (red-green variant)
- Tritanopia (blue-yellow)

**GNOME:**
```bash
gsettings set org.gnome.desktop.a11y.color-filters enabled true
gsettings set org.gnome.desktop.a11y.color-filters mode 'deuteranopia'
```

**Tools:**
```bash
# Use redshift for temperature adjustment
redshift-gtk

# Start redshift daemon
redshift -l 40.7128:-74.0060  # NYC coordinates
```

#### Font Enhancement
Larger, clearer fonts system-wide.

**Increase Font Size:**
- Settings > Appearance > Text Size
- Or adjust zoom level

**Available Fonts:**
- Liberation (default)
- Ubuntu
- DejaVu
- Noto (CJK support)

**Install More Fonts:**
```bash
sudo apt-get install fonts-noto fonts-noto-cjk
```

### Keyboard Accessibility

#### Sticky Keys
Allow key combinations without holding multiple keys.

**Enable:**
- Settings > Accessibility > Keyboard > Sticky Keys
- Modifier keys "stick" when pressed once

**Usage:**
```
Press Shift once → Shift is active
Type 'a' → outputs 'A'
Shift deactivates automatically
```

**Benefits:**
- One-handed operation
- Easier for users with coordination difficulties
- Reduced RSI

#### Slow Keys
Add delay before accepting key presses.

**Enable:**
- Settings > Accessibility > Keyboard > Slow Keys
- Default delay: 500ms

**Adjust Delay:**
```bash
# Edit accessibility config
sudo nano /etc/pentaos/accessibility/config
# Change KEY_REPEAT_DELAY value
```

#### Bounce Keys
Ignore rapid duplicate key presses.

**Enable:**
- Settings > Accessibility > Keyboard > Bounce Keys
- Prevents accidental double-presses

### Virtual Keyboards

#### Onboard
On-screen keyboard for touch input.

**Launch:**
```bash
onboard
```

**Features:**
- Touch-friendly large keys
- Customizable layout
- Word prediction
- Auto-hide when not needed

**Configuration:**
```bash
# Launch settings
onboard --show-settings
```

#### Florence
Alternative on-screen keyboard.

**Launch:**
```bash
florence
```

**Features:**
- Multiple keyboard layouts
- Themes and customization
- XKB support
- Standalone or integrated mode

### Alternative Input Devices

#### Joystick/Gamepad Support

**Check Devices:**
```bash
ls /dev/input/js*
jstest /dev/input/js0
```

**Install Joystick Tools:**
```bash
sudo apt-get install -y joystick jstest-gtk
```

**Test Joystick:**
```bash
jstest-gtk
```

#### Controller to Keyboard Mapping

**AntiMicroX** - Map game controllers to keyboard/mouse.

**Launch:**
```bash
antimicrox
```

**Create Profile:**
1. Open AntiMicroX
2. Connect controller
3. Map buttons to keyboard keys
4. Save profile
5. Load on startup

**Example Mapping:**
- Button A → Enter
- D-Pad → Arrow keys
- Analog stick → Mouse movement

### Motor Accessibility

#### Mouse Keys
Control mouse with number pad.

**Enable:**
- Settings > Accessibility > Mouse > Mouse Keys
- Use numeric keypad to move cursor

**Number Pad Mapping:**
```
7=Move Up-Left    8=Move Up      9=Move Up-Right
4=Move Left       5=Click        6=Move Right
1=Move Down-Left  2=Move Down    3=Move Down-Right
0=Drag            .=Release Drag
```

#### Eye Tracking
Control computer with eye movements.

**Tools:**
```bash
sudo apt-get install -y ogama  # Eye tracker application
```

### Auditory Accessibility

#### Visual Alerts
Replace or supplement audio notifications.

**Enable:**
- Settings > Sound > Visual Alerts
- Flash screen for notifications
- Visual bell for system alerts

**Configure:**
```bash
gsettings set org.gnome.desktop.a11y.applications screen-reader-enabled true
```

#### Subtitles & Captions
For video playback.

**VLC:**
```bash
vlc --sub-file=subtitle.srt video.mp4
```

**YouTube:**
- Enable captions with CC button
- Available for most videos

#### Text-to-Speech
Convert text to audio.

**Command Line:**
```bash
# Using espeak
espeak "Text to read aloud" -s 150 -p 50

# Using festival
echo "Text to read" | festival --tts
```

**In Applications:**
- Select text > right-click > Read Aloud
- Available in many applications

### Cognitive Accessibility

#### Focus Mode
Reduce distractions, show only essential UI.

**Enable in GNOME:**
```bash
gsettings set org.gnome.desktop.a11y.cognitive focus-mode true
```

**Benefits:**
- Fewer visual distractions
- Simpler navigation
- Reduced cognitive load

#### Notification Simplification
Show simpler, fewer notifications.

**Configure:**
```bash
# Edit config
sudo nano /etc/pentaos/accessibility/config
# Set ENABLE_NOTIFICATIONS_SIMPLIFICATION=true
```

#### Text Simplification
Use simpler language in menus.

**Tools:**
```bash
# Simple text viewer
less important-text.txt
```

## System Settings

### GNOME Accessibility Settings

**Access:**
1. Open Settings
2. Click "Accessibility" (left sidebar)
3. Browse options:
   - Seeing (visual aids)
   - Hearing (audio/captions)
   - Typing (keyboard)
   - Pointing & Clicking (mouse/alternatives)
   - Spell Check (writing aids)

### KDE Accessibility Settings

**Access:**
1. System Settings > Accessibility
2. Options:
   - Bell
   - Keyboard Filters
   - Mouse
   - Fonts
   - Colors
   - Actions for Keys

### XFCE Accessibility Settings

**Access:**
1. Settings > Accessibility
2. Keyboard
3. Mouse

## Helper Tools

### Accessibility Quick Start

```bash
pentaos-accessibility
```

Displays:
- All installed tools
- Quick launch commands
- Configuration tips
- Documentation links

## Configuration Files

### Main Configuration

```
/etc/pentaos/accessibility/config
```

**Editable Settings:**
- Screen reader enable/disable
- Visual aid preferences
- Keyboard timing settings
- Color blind mode
- Font scaling

**Edit:**
```bash
sudo nano /etc/pentaos/accessibility/config
```

## Troubleshooting

### Screen Reader Not Working

**Problem:** Orca won't start

**Solutions:**
```bash
# Check if installed
which orca

# Install if missing
sudo apt-get install -y orca

# Start with verbose output
orca -d

# Check logs
cat ~/.local/share/orca/profile
```

### Magnifier Too Slow

**Problem:** Screen magnification is sluggish

**Solutions:**
1. Disable other visual effects
2. Reduce magnification level
3. Close unnecessary applications
4. Check RAM usage: `free -h`

### Virtual Keyboard Not Appearing

**Problem:** Onboard/Florence won't launch

**Solutions:**
```bash
# Check installation
apt-cache search onboard

# Reinstall
sudo apt-get install --reinstall onboard

# Start with debug output
onboard --log-level=debug
```

### Joystick Not Detected

**Problem:** Controller not recognized

**Solutions:**
```bash
# Check device
ls /dev/input/

# Check permissions
sudo usermod -a -G input $USER

# Log out and back in

# Test
jstest /dev/input/js0
```

## Accessibility Tips

### For Vision Impairment
1. Enable screen reader (Orca)
2. Increase text size
3. Use high contrast mode
4. Install Braille display (if available)

### For Motor Impairment
1. Enable sticky keys (hold modifiers)
2. Enable slow keys (extra time)
3. Use virtual keyboard or alternatives
4. Map controllers if hand-limited

### For Hearing Impairment
1. Enable visual alerts
2. Enable captions in media
3. Use text chat for communication
4. Adjust system sounds

### For Cognitive Difficulty
1. Enable focus mode
2. Simplify notifications
3. Use text-to-speech
4. Create reminders and alarms

## Accessibility Standards

### WCAG 2.1 Compliance
- Perceivable (visible/audible)
- Operable (keyboard accessible)
- Understandable (clear language)
- Robust (compatible with tools)

### W3C Guidelines
PentaOS aims to follow:
- Web Content Accessibility Guidelines
- User Agent Accessibility Guidelines
- Authoring Tool Accessibility Guidelines

## Resources

### Official Documentation
- [GNOME Accessibility](https://help.gnome.org/users/gnome-access-guide/)
- [KDE Accessibility](https://community.kde.org/Accessibility)
- [XFCE Accessibility](https://docs.xfce.org/)

### External Resources
- [WebAIM](https://webaim.org/) - Web accessibility info
- [Accessibility.com](https://www.accessibility.com/) - Resources
- [The A11Y Project](https://www.a11yproject.com/) - Community

## Community & Support

### Getting Help
1. Check this documentation
2. Review system settings
3. Visit accessibility forums
4. Contact community support

### Report Issues
- Found accessibility problem?
- Let us know: GitHub Issues
- Suggest improvements
- Share your experiences

## FAQ

**Q: Can I use PentaOS without a mouse?**
A: Yes. Enable sticky keys, slow keys, and mouse keys. Keyboard shortcuts work everywhere.

**Q: What if I'm color blind?**
A: Enable color blind filter matching your type. Redshift adjusts colors dynamically.

**Q: Can I use voice commands?**
A: Use espeak for text-to-speech output. Speech recognition requires additional setup (Julius or CMU Sphinx).

**Q: Is everything keyboard accessible?**
A: Yes. GNOME, KDE, and XFCE are keyboard-accessible. Tab through UI, enter to select.

**Q: Can I increase font size globally?**
A: Yes. Settings > Appearance > Text Size. Affects system-wide fonts.

**Q: What about eyetracking?**
A: Ogama is available. Requires compatible eyetracker hardware.

**Q: Can I use my gaming controller?**
A: Yes. AntiMicroX maps controller buttons to keyboard. Create custom profiles.

**Q: Are subtitles available for everything?**
A: Not all content. VLC, YouTube, and streaming services support captions.

---

**Last Updated:** 2026-09-13

**Accessibility Team:** Committed to inclusive computing

**Questions?** See docs/ACCESSIBILITY.md or run `pentaos-accessibility`
