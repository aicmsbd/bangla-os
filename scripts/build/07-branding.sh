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
PRETTY_NAME="Bangla OS 1.0 (Padma)"
NAME="Bangla OS"
VERSION_ID="1.0"
VERSION="1.0 (Padma)"
VERSION_CODENAME=padma
ID=bangla-os
ID_LIKE=debian
HOME_URL="https://github.com/bangla-os/bangla-os"
SUPPORT_URL="https://github.com/bangla-os/bangla-os/issues"
BUG_REPORT_URL="https://github.com/bangla-os/bangla-os/issues"
LOGO=bangla-os
EOF

hostnamectl set-hostname bangla-os 2>/dev/null || echo "bangla-os" > /etc/hostname

cat > /etc/issue << 'EOF'
Bangla OS 1.0 (Padma) — বাঙলা OS
Welcome / স্বাগতম

EOF

# Temporary wallpaper if provided
WALLPAPER="$PROJECT_ROOT/assets/branding/wallpaper.jpg"
if [[ -f "$WALLPAPER" ]]; then
    install -d /usr/share/backgrounds/bangla-os
    cp "$WALLPAPER" /usr/share/backgrounds/bangla-os/default.jpg
fi

apt_install neofetch 2>/dev/null || true

log "Branding applied."
