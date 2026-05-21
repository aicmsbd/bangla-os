#!/bin/bash
# Phase 1.6: Browser and essential apps
set -euo pipefail
source "$(dirname "$0")/00-common.sh"
require_root

log "Phase 1.6 — Essential applications"

apt_install \
    firefox-esr firefox-esr-l10n-bn \
    mousepad ristretto vlc \
    libavcodec-extra ffmpeg \
    gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad gstreamer1.0-libav

# Default browser
update-alternatives --set x-www-browser /usr/bin/firefox-esr 2>/dev/null || true

log "Essential apps installed."
