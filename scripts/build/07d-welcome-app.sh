#!/bin/bash
# Phase 2.2: First-run welcome app (GTK3)
set -euo pipefail
source "$(dirname "$0")/00-common.sh"
require_root

log "Phase 2.2 — Welcome app"

APP_SRC="$PROJECT_ROOT/assets/apps/bangla-welcome"
if [[ ! -f "$APP_SRC/bangla-welcome.py" ]]; then
    log "Welcome app sources not found; skipping."
    exit 0
fi

apt_install python3-gi gir1.2-gtk-3.0 python3-gi-cairo 2>/dev/null || \
    apt_install python3-gi gir1.2-gtk-3.0

install -m 755 "$APP_SRC/bangla-welcome.py" /usr/bin/bangla-welcome
install -m 644 "$APP_SRC/bangla-welcome.desktop" /usr/share/applications/bangla-welcome.desktop

install_skelf() {
    local base="$1"
    install -d "$base/.config/autostart"
    install -m 644 "$APP_SRC/autostart.desktop" "$base/.config/autostart/bangla-welcome.desktop"
}

install_skelf /etc/skel
[[ -d /home/live ]] && install_skelf /home/live && chown -R live:live /home/live/.config 2>/dev/null || true
[[ -d /home/banglaos ]] && install_skelf /home/banglaos && chown -R banglaos:banglaos /home/banglaos/.config 2>/dev/null || true

log "Welcome app installed (/usr/bin/bangla-welcome, autostart on first login)."
