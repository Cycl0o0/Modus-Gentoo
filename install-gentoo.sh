#!/bin/bash

#  ███╗   ███╗ ██████╗ ██████╗ ██╗   ██╗███████╗
#  ████╗ ████║██╔═══██╗██╔══██╗██║   ██║██╔════╝
#  ██╔████╔██║██║   ██║██║  ██║██║   ██║███████╗
#  ██║╚██╔╝██║██║   ██║██║  ██║██║   ██║╚════██║
#  ██║ ╚═╝ ██║╚██████╔╝██████╔╝╚██████╔╝███████║
#  ╚═╝     ╚═╝ ╚═════╝ ╚═════╝  ╚═════╝ ╚══════╝
#
#  A hackable shell for Hyprland
#  Installation Script for Gentoo Linux
#
#  Repository: https://github.com/S4NKALP/Modus
#  License: GPLv3

set -e
set -u
set -o pipefail

# Options
USE_BINPKG=false
EMERGE_OPTS="-n --quiet"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--binpkg)
            USE_BINPKG=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -b, --binpkg    Use binary packages when available (--getbinpkg)"
            echo "  -h, --help      Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

if [ "$USE_BINPKG" = true ]; then
    EMERGE_OPTS="-n --quiet --getbinpkg"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.config/Modus"

# Packages available via emerge
EMERGE_PACKAGES=(
    media-video/ffmpeg
    media-gfx/imagemagick
    x11-libs/libnotify
    media-sound/playerctl
    dev-python/pillow
    dev-python/pygobject
    dev-python/requests
    dev-python/numpy
    dev-python/psutil
    x11-misc/slurp
    gui-apps/wl-clipboard
    media-video/wf-recorder
    sys-power/acpi
    app-misc/brightnessctl
    gui-apps/swappy
    net-wireless/gnome-bluetooth
)

# Packages from overlays (guru/hyproverlay) requiring ~amd64
OVERLAY_PACKAGES=(
    gui-apps/hyprsunset
    x11-misc/matugen
    gui-libs/gtk-session-lock
    app-misc/cliphist
    gui-apps/uwsm
)

# Colors and formatting
if [ -t 1 ]; then
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1)
    CYAN=$(tput setaf 6)
    BLUE=$(tput setaf 4)
    BOLD=$(tput bold)
    DIM=$(tput dim)
    RESET=$(tput sgr0)
else
    GREEN="" YELLOW="" RED="" CYAN="" BLUE="" BOLD="" DIM="" RESET=""
fi

# Status symbols
ARROW="->"
CHECK="[OK]"
CROSS="[X]"
INFO="[i]"
WARN="[!]"

# Progress tracking
TOTAL_STEPS=8
CURRENT_STEP=0

progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo -e "\n${BOLD}${BLUE}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} ${BOLD}$1${RESET}"
}

step() {
    echo -e "  ${CYAN}${ARROW}${RESET} $1"
}

success() {
    echo -e "  ${GREEN}${CHECK}${RESET} ${GREEN}$1${RESET}"
}

warn() {
    echo -e "  ${YELLOW}${WARN}${RESET} ${YELLOW}$1${RESET}"
}

error() {
    echo -e "\n${RED}${CROSS}${RESET} ${RED}${BOLD}ERROR:${RESET} ${RED}$1${RESET}\n" >&2
}

info() {
    echo -e "  ${BLUE}${INFO}${RESET} ${DIM}$1${RESET}"
}

# Header
clear
echo -e "${BOLD}${CYAN}"
cat << "EOF"
  ███╗   ███╗ ██████╗ ██████╗ ██╗   ██╗███████╗
  ████╗ ████║██╔═══██╗██╔══██╗██║   ██║██╔════╝
  ██╔████╔██║██║   ██║██║  ██║██║   ██║███████╗
  ██║╚██╔╝██║██║   ██║██║  ██║██║   ██║╚════██║
  ██║ ╚═╝ ██║╚██████╔╝██████╔╝╚██████╔╝███████║
  ╚═╝     ╚═╝ ╚═════╝ ╚═════╝  ╚═════╝ ╚══════╝
EOF
echo -e "${RESET}"
echo -e "${BOLD}  A hackable shell for Hyprland${RESET}"
echo -e "${DIM}  Gentoo Installation Script v1.0${RESET}"
if [ "$USE_BINPKG" = true ]; then
    echo -e "${DIM}  Binary packages: enabled${RESET}\n"
else
    echo -e "${DIM}  Binary packages: disabled (use -b to enable)${RESET}\n"
fi

# Pre-flight checks
progress "Pre-flight checks"

step "Checking operating system..."
if ! grep -qi "gentoo" /etc/os-release; then
    error "This script requires Gentoo Linux"
    exit 1
fi
success "Gentoo Linux detected"

step "Checking user permissions..."
if [ "$(id -u)" -eq 0 ]; then
    error "Please run this script as a regular user, not as root"
    exit 1
fi
success "Running as regular user"

step "Checking system requirements..."
missing_tools=()
command -v git &>/dev/null || missing_tools+=("git")
command -v python3 &>/dev/null || missing_tools+=("python")
command -v cargo &>/dev/null || missing_tools+=("rust/cargo")
command -v emerge &>/dev/null || missing_tools+=("portage")

if [ ${#missing_tools[@]} -gt 0 ]; then
    error "Missing required tools: ${missing_tools[*]}"
    exit 1
fi
success "All requirements met"

step "Checking overlays..."
overlays_ok=true
if ! [ -d /var/db/repos/guru ]; then
    warn "GURU overlay not found"
    info "Enable with: eselect repository enable guru && emerge --sync guru"
    overlays_ok=false
fi
if ! [ -d /var/db/repos/hyproverlay ]; then
    warn "hyproverlay not found"
    info "Enable with: eselect repository enable hyproverlay && emerge --sync hyproverlay"
    overlays_ok=false
fi
if [ "$overlays_ok" = true ]; then
    success "Required overlays available"
else
    read -rp "  ${YELLOW}${WARN}${RESET} Continue anyway? (y/N): " cont
    if [[ ! "$cont" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Sudo authentication
progress "Requesting permissions"

info "Package installation requires root privileges"
echo ""
if ! sudo -v; then
    error "Sudo authentication failed"
    exit 1
fi
success "Permissions granted"

# Keep sudo alive
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &
SUDO_KEEPER_PID=$!
trap "kill $SUDO_KEEPER_PID 2>/dev/null || true" EXIT INT TERM

# Package keywords setup
progress "Configuring package keywords"

KEYWORDS_FILE="/etc/portage/package.accept_keywords/modus"
step "Setting up ~amd64 keywords for overlay packages..."

keywords_content=""
for pkg in "${OVERLAY_PACKAGES[@]}"; do
    keywords_content+="${pkg} ~amd64"$'\n'
done

if [ -f "$KEYWORDS_FILE" ]; then
    info "Keywords file already exists, checking..."
    needs_update=false
    for pkg in "${OVERLAY_PACKAGES[@]}"; do
        if ! grep -q "^${pkg}" "$KEYWORDS_FILE" 2>/dev/null; then
            needs_update=true
            break
        fi
    done
    if [ "$needs_update" = true ]; then
        echo "$keywords_content" | sudo tee "$KEYWORDS_FILE" > /dev/null
        success "Keywords file updated"
    else
        success "Keywords already configured"
    fi
else
    echo "$keywords_content" | sudo tee "$KEYWORDS_FILE" > /dev/null
    success "Keywords file created"
fi

# System packages installation
progress "Installing system packages"

if [ "$USE_BINPKG" = true ]; then
    info "Binary packages enabled (--getbinpkg)"
fi

step "Installing packages from main repository..."
failed_pkgs=()
for pkg in "${EMERGE_PACKAGES[@]}"; do
    if ! sudo emerge $EMERGE_OPTS "$pkg" 2>/dev/null; then
        failed_pkgs+=("$pkg")
    fi
    printf "\r  ${CYAN}${ARROW}${RESET} Emerged: %s" "$pkg"
done
echo ""

if [ ${#failed_pkgs[@]} -eq 0 ]; then
    success "Main packages installed"
else
    warn "Some packages failed: ${failed_pkgs[*]}"
fi

step "Installing packages from overlays..."
failed_overlay=()
for pkg in "${OVERLAY_PACKAGES[@]}"; do
    if ! sudo emerge $EMERGE_OPTS "$pkg" 2>/dev/null; then
        failed_overlay+=("$pkg")
    fi
    printf "\r  ${CYAN}${ARROW}${RESET} Emerged: %s" "$pkg"
done
echo ""

if [ ${#failed_overlay[@]} -eq 0 ]; then
    success "Overlay packages installed"
else
    warn "Some overlay packages failed: ${failed_overlay[*]}"
    info "You may need to install these manually"
fi

# Install swww via cargo
progress "Installing swww (wallpaper daemon)"

if command -v swww &>/dev/null; then
    success "swww already installed"
else
    step "Building swww from source (this may take a while)..."
    if cargo install --git https://github.com/LGFae/swww.git 2>/dev/null; then
        success "swww installed"
    else
        warn "Failed to install swww via cargo"
        info "Try manually: cargo install --git https://github.com/LGFae/swww.git"
    fi
fi

# Setup Modus directory
progress "Setting up Modus"

if [ "$SCRIPT_DIR" != "$INSTALL_DIR" ]; then
    step "Copying Modus to ~/.config/Modus..."
    mkdir -p "$INSTALL_DIR"
    cp -r "$SCRIPT_DIR"/* "$INSTALL_DIR"/
    success "Modus copied to config directory"
else
    success "Modus already in correct location"
fi

# Python virtual environment and dependencies
progress "Setting up Python environment"

cd "$INSTALL_DIR"

step "Creating virtual environment..."
python3 -m venv .venv
success "Virtual environment created"

step "Activating virtual environment..."
source .venv/bin/activate
success "Virtual environment activated"

step "Installing Python dependencies..."
pip install --quiet --upgrade pip
pip install --quiet -r requirements.txt
success "Python dependencies installed"

step "Installing Fabric framework..."
pip install --quiet --no-deps git+https://github.com/Fabric-Development/fabric.git
success "Fabric installed"

deactivate

# Hyprland configuration
progress "Configuring Hyprland"

HYPR_CONFIG="$HOME/.config/hypr/hyprland.conf"
MODUS_CONF_LINE="source = ~/.config/Modus/config/hypr/modus.conf"

if [ -f "$HYPR_CONFIG" ]; then
    step "Checking Hyprland configuration..."
    if grep -qF "Modus" "$HYPR_CONFIG"; then
        success "Modus configuration already sourced"
    else
        step "Adding Modus configuration to Hyprland..."
        echo "" >> "$HYPR_CONFIG"
        echo "# Modus shell configuration" >> "$HYPR_CONFIG"
        echo "$MODUS_CONF_LINE" >> "$HYPR_CONFIG"
        success "Modus configuration added to Hyprland"
    fi
else
    warn "Hyprland config not found at $HYPR_CONFIG"
    info "Add this line manually: $MODUS_CONF_LINE"
fi

# Create launcher script
step "Creating launcher script..."
cat > "$INSTALL_DIR/start-modus.sh" << 'LAUNCHER'
#!/bin/bash
cd ~/.config/Modus
source .venv/bin/activate
exec python main.py "$@"
LAUNCHER
chmod +x "$INSTALL_DIR/start-modus.sh"
success "Launcher script created"

# Update modus.conf to use venv
step "Updating modus.conf for venv..."
sed -i 's|uwsm app -- python ~/.config/Modus/main.py|uwsm app -- ~/.config/Modus/start-modus.sh|g' "$INSTALL_DIR/config/hypr/modus.conf"
sed -i 's|python $HOME/.config/Modus/main.py|~/.config/Modus/start-modus.sh|g' "$INSTALL_DIR/config/hypr/modus.conf"
success "modus.conf updated"

# Completion
echo ""
echo -e "${GREEN}${BOLD}╔════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║                                        ║${RESET}"
echo -e "${GREEN}${BOLD}║     Installation completed!            ║${RESET}"
echo -e "${GREEN}${BOLD}║                                        ║${RESET}"
echo -e "${GREEN}${BOLD}╚════════════════════════════════════════╝${RESET}"
echo ""
info "Config location: ${INSTALL_DIR}"
info "To start Modus: ~/.config/Modus/start-modus.sh"
info "Or restart Hyprland to auto-start Modus"
echo ""
echo -e "${YELLOW}${WARN}${RESET} ${YELLOW}Post-installation:${RESET}"
echo "  - Review ~/.config/Modus/config/hypr/modus.conf"
echo "  - Install fonts: Inter, Roboto, Material Design Icons"
echo "  - Optional: Install MacTahoe icon/GTK/cursor themes"
echo ""
