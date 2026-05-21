#!/bin/bash
# Phase 1.4: Bengali language support
# [E:MIX-3] Core differentiator — full i18n stack
set -euo pipefail
source "$(dirname "$0")/00-common.sh"
require_root

log "Phase 1.4 — Bengali language support"

apt_install \
    fonts-beng fonts-beng-extra fonts-lohit-beng-bengali \
    ibus ibus-m17n ibus-gtk ibus-gtk3 ibus-gtk4 \
    im-config locales

# Generate locales
sed -i '/bn_BD.UTF-8/s/^# //' /etc/locale.gen
sed -i '/en_US.UTF-8/s/^# //' /etc/locale.gen
locale-gen

# OpenBangla Keyboard from GitHub releases (Debian 12 build)
OBK_DEB="/tmp/openbangla-keyboard-debian12.deb"
OBK_URL="https://github.com/OpenBangla/OpenBangla-Keyboard/releases/download/2.0.0/OpenBangla-Keyboard_2.0.0-debian12.deb"

log "Downloading OpenBangla Keyboard 2.0.0 (debian12)..."
curl -fsSL -o "$OBK_DEB" "$OBK_URL"
apt_install ./"$OBK_DEB"
rm -f "$OBK_DEB"

# Optional extra fonts from project assets
FONTS_DIR="$PROJECT_ROOT/assets/fonts"
if [[ -d "$FONTS_DIR" ]] && ls "$FONTS_DIR"/*.ttf &>/dev/null 2>&1; then
    install -d /usr/share/fonts/truetype/bangla-os
    cp "$FONTS_DIR"/*.ttf /usr/share/fonts/truetype/bangla-os/ 2>/dev/null || true
    fc-cache -fv
fi

# Configure ibus for banglaos user
for SKEL in /etc/skel /home/banglaos; do
    [[ -d "$SKEL" ]] || continue
    mkdir -p "$SKEL/.config/autostart"
    cat > "$SKEL/.config/autostart/ibus-autostart.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=IBus
Exec=ibus-daemon -drx
X-GNOME-Autostart-enabled=true
EOF
done

if id banglaos &>/dev/null; then
    chown -R banglaos:banglaos /home/banglaos/.config 2>/dev/null || true
    sudo -u banglaos im-config -n ibus 2>/dev/null || true
fi

log "Bengali support installed. After login: ibus-setup → add Bengali (OpenBangla)."
