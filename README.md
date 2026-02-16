<p align="center">
  <img src="assets/modus.png" height="200" alt="Logo">
</p>

<p align="center">
  <b>Forked for Gentoo Linux</b> from <a href="https://github.com/S4NKALP/Modus">S4NKALP/Modus</a>
</p>

<p align="center">
  <a href="https://github.com/hyprwm/Hyprland">
    <img src="https://img.shields.io/badge/A%20hackable%20shell%20for-Hyprland-0092CD?style=for-the-badge&logo=linux&color=0092CD&logoColor=D9E0EE&labelColor=000000" alt="A hackable shell for Hyprland">
  </a>
  <a href="https://github.com/Fabric-Development/fabric/">
    <img src="https://img.shields.io/badge/Powered%20by-Fabric-FAFAFA?style=for-the-badge&logo=python&color=FAFAFA&logoColor=D9E0EE&labelColor=000000" alt="Powered by Fabric">
  </a>
  </p>

<div align="center">

[![GitHub stars](https://img.shields.io/github/stars/cycl0o0/Modus-Gentoo?style=for-the-badge&logo=github&color=FFB686&logoColor=D9E0EE&labelColor=292324)](https://github.com/cycl0o0/Modus-Gentoo/stargazers)
[![Hyprland](https://img.shields.io/badge/Made%20for-Hyprland-pink?style=for-the-badge&logo=linux&logoColor=D9E0EE&labelColor=292324&color=C6A0F6)](https://hyprland.org/)
[![Maintained](https://img.shields.io/badge/Maintained-Yes-blue?style=for-the-badge&logo=linux&logoColor=D9E0EE&labelColor=292324&color=3362E1)]()
[![Discord](https://dcbadge.limes.pink/api/server/https://discord.gg/tRFxkbQ3Zq)](https://discord.gg/tRFxkbQ3Zq)

</div>

<br>

<figure>
  <h2>Home Screen:</h2>
  <img src="assets/screenshots/home.png" alt="fabric">
  <br/>
  <h2>Lock Screen:</h2>
    <img src="assets/screenshots/lock.png" alt="fabric">
</figure>
<br>


## Installation (Gentoo)

> [!CAUTION]
> - You need a working installation of Hyprland and knowledge of how it works
> - Requires `guru` and `hyproverlay` overlays enabled

### Prerequisites

Enable required overlays:
```bash
sudo eselect repository enable guru
sudo eselect repository enable hyproverlay
sudo emerge --sync guru hyproverlay
```

### Quick Install

```bash
git clone https://github.com/cycl0o0/Modus-Gentoo ~/.config/Modus
cd ~/.config/Modus
./install-gentoo.sh
```

Use `-b` flag to enable binary packages if available:
```bash
./install-gentoo.sh -b
```

### Manual Installation

```bash
# Install dependencies from portage
sudo emerge -n media-video/ffmpeg media-gfx/imagemagick x11-libs/libnotify \
    media-sound/playerctl dev-python/pillow dev-python/pygobject \
    dev-python/requests dev-python/numpy dev-python/psutil \
    x11-misc/slurp gui-apps/wl-clipboard media-video/wf-recorder \
    sys-power/acpi app-misc/brightnessctl gui-apps/swappy

# Packages from overlays (need ~amd64 keyword)
echo "gui-apps/hyprsunset ~amd64" | sudo tee -a /etc/portage/package.accept_keywords/modus
echo "x11-misc/matugen ~amd64" | sudo tee -a /etc/portage/package.accept_keywords/modus
echo "gui-libs/gtk-session-lock ~amd64" | sudo tee -a /etc/portage/package.accept_keywords/modus
echo "app-misc/cliphist ~amd64" | sudo tee -a /etc/portage/package.accept_keywords/modus
echo "gui-apps/uwsm ~amd64" | sudo tee -a /etc/portage/package.accept_keywords/modus

sudo emerge -n gui-apps/hyprsunset x11-misc/matugen gui-libs/gtk-session-lock app-misc/cliphist gui-apps/uwsm

# Install swww via cargo
cargo install --git https://github.com/LGFae/swww.git

# Clone and setup
git clone https://github.com/cycl0o0/Modus-Gentoo ~/.config/Modus
cd ~/.config/Modus
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pip install --no-deps git+https://github.com/Fabric-Development/fabric.git
```

> [!TIP]
> ## Post Installation
> - Install recommended [Icon theme](https://github.com/vinceliuice/MacTahoe-icon-theme), [GTK theme](https://github.com/vinceliuice/MacTahoe-gtk-theme) and [Cursor Theme](https://github.com/vinceliuice/MacTahoe-icon-theme/tree/main/cursors)
> - Check `config/hypr/modus.conf` edit it according to your device and copy it to your hyprland config
> - For Lock Screen bind keys to `python lock.py`

## Todo

- [x] Launcher
- [x] Lock Screen
- [x] Dock
- [x] Notification
- [x] Control Center
- [x] Music Player
- [x] Desktop Widgets
- [x] New Launcher (like Spotlight)
- [ ] Settings
- [x] ~~Magnifier hover effect on Dock~~
- [x] ~~New Application Switcher~~
- [x] Panel Widget
- [x] MacOS like Widget
- [x] Expandable Notification Centre
- [ ] Installation Script
- [ ] Proper Documentation
- [ ] Pomodoro Timer Widget
- [x] To-do List Widget

## Bug Fixes (the bug found till now)

- [x] WiFi
- [x] wifi off button looks bigger
- [x] Metadata Changes delay in Media Player
- [x] Active Window Title showing `Unknown` when no active window
- [x] Notification Escape Char Issue

## Team

- [SANKALP](https://github.com/S4NKALP/)
- [tr1x_em](https://github.com/tr1xem)

## Special Thanks

A big thank you to the following people for their incredible help with code and creative ideas. Your help made a real difference!

- [darsh](https://github.com/its-darsh): for creating Fabric, which made everything possible.
- [gummy bear album](https://github.com/muhchaudhary): for sharing fantastic code snippets that saved me time and effort.
- [axenide](https://github.com/Axenide): for the amazing config that not only inspired parts of mine but also provided some gems I couldn’t resist borrowing.
- [E3nviction](https://github.com/E3nviction/): for code snippets and ideas that were incredibly helpful.

I truly appreciate your support
