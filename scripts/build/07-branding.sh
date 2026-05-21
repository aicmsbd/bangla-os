#!/bin/bash
# Phase 1.8: Bangla OS branding
set -euo pipefail
source "$(dirname "$0")/00-common.sh"
require_root

log "Phase 1.8 — Branding"

# Backup original os-release
if [[ ! -f /etc/os-release.debian ]]; then
    cp /etc/os-release /etc/os-release.debian
fi

cat > /etc/os-release << 'EOF'
PRETTY_NAME="Bangla OS 1.0.1 (Padma)"
NAME="Bangla OS"
VERSION_ID="1.0.1"
VERSION="1.0.1 (Padma)"
VERSION_CODENAME=padma
ID=bangla-os
ID_LIKE=debian
HOME_URL="https://github.com/aicmsbd/bangla-os"
SUPPORT_URL="https://github.com/aicmsbd/bangla-os/issues"
BUG_REPORT_URL="https://github.com/aicmsbd/bangla-os/issues"
LOGO=bangla-os
EOF

hostnamectl set-hostname bangla-os 2>/dev/null || echo "bangla-os" > /etc/hostname

cat > /etc/issue << 'EOF'
Bangla OS 1.0.1 (Padma) — বাঙলা OS
Welcome / স্বাগতম

EOF

# Temporary wallpaper if provided
WALLPAPER="$PROJECT_ROOT/assets/branding/wallpaper.jpg"
if [[ -f "$WALLPAPER" ]]; then
    install -d /usr/share/backgrounds/bangla-os
    cp "$WALLPAPER" /usr/share/backgrounds/bangla-os/default.jpg
fi

# Logo PNGs and icons
PNG_DIR="$PROJECT_ROOT/assets/branding/png"
if [[ -d "$PNG_DIR" ]]; then
    install -d /usr/share/icons/hicolor/{16x16,32x32,48x48,128x128,256x256,512x512}/apps
    [[ -f "$PNG_DIR/bangla-os-16.png" ]] && cp "$PNG_DIR/bangla-os-16.png" /usr/share/icons/hicolor/16x16/apps/bangla-os.png
    [[ -f "$PNG_DIR/bangla-os-32.png" ]] && cp "$PNG_DIR/bangla-os-32.png" /usr/share/icons/hicolor/32x32/apps/bangla-os.png
    [[ -f "$PNG_DIR/bangla-os-48.png" ]] && cp "$PNG_DIR/bangla-os-48.png" /usr/share/icons/hicolor/48x48/apps/bangla-os.png
    [[ -f "$PNG_DIR/bangla-os-128.png" ]] && cp "$PNG_DIR/bangla-os-128.png" /usr/share/icons/hicolor/128x128/apps/bangla-os.png
    [[ -f "$PNG_DIR/bangla-os-256.png" ]] && cp "$PNG_DIR/bangla-os-256.png" /usr/share/icons/hicolor/256x256/apps/bangla-os.png
    [[ -f "$PNG_DIR/bangla-os-512.png" ]] && cp "$PNG_DIR/bangla-os-512.png" /usr/share/icons/hicolor/512x512/apps/bangla-os.png
    gtk-update-icon-cache /usr/share/icons/hicolor 2>/dev/null || true
fi

# LightDM greeter background
if [[ -f /usr/share/backgrounds/bangla-os/default.jpg ]]; then
    GREETER_CONF="/etc/lightdm/lightdm-gtk-greeter.conf"
    if [[ -f "$GREETER_CONF" ]]; then
        sed -i 's|^background=.*|background=/usr/share/backgrounds/bangla-os/default.jpg|' "$GREETER_CONF" 2>/dev/null || true
        grep -q '^background=' "$GREETER_CONF" || echo "background=/usr/share/backgrounds/bangla-os/default.jpg" >> "$GREETER_CONF"
    fi
fi

apt_install neofetch 2>/dev/null || true

# neofetch config for live + new users (Bangladesh green colors)
NEOFETCH_SRC="$PROJECT_ROOT/assets/branding/neofetch/config.conf"
if [[ -f "$NEOFETCH_SRC" ]]; then
    install -d /etc/skel/.config/neofetch /usr/share/bangla-os
    cp "$NEOFETCH_SRC" /etc/skel/.config/neofetch/config.conf
    cp "$NEOFETCH_SRC" /usr/share/bangla-os/neofetch.conf
    if [[ -d /home/live ]]; then
        install -d /home/live/.config/neofetch
        cp "$NEOFETCH_SRC" /home/live/.config/neofetch/config.conf
        chown -R live:live /home/live/.config 2>/dev/null || true
    fi
fi

if [[ -f "$(dirname "$0")/07b-calamares-branding.sh" ]]; then
    bash "$(dirname "$0")/07b-calamares-branding.sh"
fi

if [[ -f "$(dirname "$0")/07c-boot-branding.sh" ]]; then
    bash "$(dirname "$0")/07c-boot-branding.sh"
fi

log "Branding applied."
