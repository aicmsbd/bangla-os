#!/bin/bash
# Phase 1.5: Windows software support (Wine, Flatpak, Bottles)
set -euo pipefail
source "$(dirname "$0")/00-common.sh"
require_root

log "Phase 1.5 — Wine and Windows compatibility"

enable_contrib_nonfree
dpkg --add-architecture i386
apt_update

# Winetricks — apt if available after contrib enabled, else upstream script
if apt-cache policy winetricks 2>/dev/null | grep -q 'Candidate: [0-9]'; then
    apt_install winetricks
else
    log "Installing winetricks from upstream..."
    install -d /usr/local/bin
    curl -fsSL -o /usr/local/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
    chmod +x /usr/local/bin/winetricks
fi

apt_install wine wine64 wine32 cabextract fonts-wine flatpak

# PlayOnLinux is optional — not always available on Debian 12
apt-get install -y --no-install-recommends playonlinux 2>/dev/null || \
    log "PlayOnLinux not available — skipping (Bottles via Flatpak covers this)."

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Bottles via Flatpak (user-level; also install system-wide for live user)
flatpak install -y flathub com.usebottles.bottles 2>/dev/null || \
    flatpak install --system -y flathub com.usebottles.bottles || true

# .exe file association via mimeapps (system default for XFCE)
cat > /usr/share/applications/wine-extension-exe.desktop << 'EOF'
[Desktop Entry]
Name=Run Windows Executable
Exec=wine start /unix %f
Type=Application
MimeType=application/x-ms-dos-executable;application/x-msi;
NoDisplay=true
EOF
update-desktop-database 2>/dev/null || true

if id banglaos &>/dev/null; then
    sudo -u banglaos WINEDLLOVERRIDES="mscoree,mshtml=" wineboot --init 2>/dev/null || true
fi

log "Wine stack installed."
