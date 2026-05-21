#!/bin/bash
# Phase 2.1: Calamares installer branding for Bangla OS
set -euo pipefail
source "$(dirname "$0")/00-common.sh"
require_root

log "Phase 2.1 — Calamares branding"

BRAND_SRC="$PROJECT_ROOT/assets/branding/calamares"
BRAND_DST="/etc/calamares/branding/bangla-os"
LOGO_PNG="$PROJECT_ROOT/assets/branding/png/bangla-os-128.png"
WALLPAPER="/usr/share/backgrounds/bangla-os/default.jpg"

install -d "$BRAND_DST"

if [[ -f "$LOGO_PNG" ]]; then
    cp "$LOGO_PNG" "$BRAND_DST/bangla-os-logo.png"
elif [[ -f "$PROJECT_ROOT/assets/branding/logo.svg" ]]; then
    if command -v rsvg-convert &>/dev/null; then
        rsvg-convert -w 128 -h 128 "$PROJECT_ROOT/assets/branding/logo.svg" -o "$BRAND_DST/bangla-os-logo.png"
    fi
fi

[[ -f "$WALLPAPER" ]] && cp "$WALLPAPER" "$BRAND_DST/welcome.png" 2>/dev/null || true
[[ -f "$BRAND_DST/welcome.png" ]] || cp "$BRAND_DST/bangla-os-logo.png" "$BRAND_DST/welcome.png" 2>/dev/null || true

cat > "$BRAND_DST/branding.desc" << 'EOF'
---
componentName:  bangla-os
strings:
    productName:         Bangla OS
    shortProductName:    Bangla OS
    version:             1.0.1
    shortVersion:        1.0.1
    bootloaderEntryName: Bangla OS
    productUrl:          https://github.com/aicmsbd/bangla-os
    supportUrl:          https://github.com/aicmsbd/bangla-os/issues
    knownIssuesUrl:      https://github.com/aicmsbd/bangla-os/issues
    releaseNotesUrl:     https://github.com/aicmsbd/bangla-os/releases
    donateUrl:           https://github.com/aicmsbd/bangla-os

images:
    productLogo:         "bangla-os-logo.png"
    productIcon:         "bangla-os-logo.png"
    productWelcome:      "welcome.png"

style:
   sidebarBackground:    "#006a4e"
   sidebarText:          "#ffffff"
   sidebarTextCurrent:   "#ffffff"
EOF

cat > "$BRAND_DST/show.qml" << 'EOF'
import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation {
    id: presentation
    function nextSlide() { presentation.goToNextSlide(); }
    Timer {
        id: autoAdvanceTimer
        interval: 6000
        running: true
        repeat: true
        onTriggered: presentation.nextSlide()
    }
    Slide { Image { source: "welcome.png"; anchors.fill: parent; fillMode: Image.PreserveAspectCrop } }
    Slide {
        centeredText: qsTr("Bangla OS 1.0.1 (Padma)\nবাঙলা OS — Bengali-first Linux")
        Text { anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
               text: qsTr("OpenBangla • XFCE • Wine • Calamares"); color: "#ffffff"; font.pixelSize: 18 }
    }
}
EOF

# Point calamares at bangla-os branding if settings exist
SETTINGS="/etc/calamares/settings.conf"
if [[ -f "$SETTINGS" ]] && ! grep -q 'branding:.*bangla-os' "$SETTINGS" 2>/dev/null; then
    sed -i 's/^branding:.*/branding: bangla-os/' "$SETTINGS" 2>/dev/null || \
        echo "branding: bangla-os" >> "$SETTINGS"
fi

log "Calamares branding installed at $BRAND_DST"
