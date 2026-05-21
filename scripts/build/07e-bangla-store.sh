#!/bin/bash
# Phase 2.3: Bangla Store (curated apt software catalog)
set -euo pipefail
source "$(dirname "$0")/00-common.sh"
require_root

log "Phase 2.3 — Bangla Store"

APP_SRC="$PROJECT_ROOT/assets/apps/bangla-store"
if [[ ! -f "$APP_SRC/bangla-store.py" ]]; then
    log "Bangla Store sources not found; skipping."
    exit 0
fi

apt_install python3-gi gir1.2-gtk-3.0 2>/dev/null || true

install -d /usr/share/bangla-os/bangla-store
install -m 755 "$APP_SRC/bangla-store.py" /usr/bin/bangla-store
install -m 644 "$APP_SRC/software.json" /usr/share/bangla-os/bangla-store/software.json
install -m 644 "$APP_SRC/bangla-store.desktop" /usr/share/applications/bangla-store.desktop

log "Bangla Store installed (/usr/bin/bangla-store)."
