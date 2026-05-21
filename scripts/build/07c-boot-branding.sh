#!/bin/bash
# Phase 2.1: Plymouth + GRUB boot branding (installed system)
set -euo pipefail
source "$(dirname "$0")/00-common.sh"
require_root

log "Phase 2.1 — Boot branding (Plymouth + GRUB)"

bash "$(dirname "$0")/generate-boot-splash.sh"

PLYMOUTH_SRC="$PROJECT_ROOT/assets/branding/plymouth"
PLYMOUTH_DST="/usr/share/plymouth/themes/bangla-os"
LOGO_PNG="$PROJECT_ROOT/assets/branding/png/bangla-os-256.png"

GRUB_SRC="$PROJECT_ROOT/assets/branding/grub"
GRUB_DST="/boot/grub/themes/bangla-os"

# Plymouth
if [[ -d "$PLYMOUTH_SRC" ]]; then
    apt_install plymouth plymouth-label 2>/dev/null || apt_install plymouth 2>/dev/null || true
    install -d "$PLYMOUTH_DST"
    cp "$PLYMOUTH_SRC/bangla-os.plymouth" "$PLYMOUTH_SRC/bangla-os.script" "$PLYMOUTH_DST/"
    if [[ -f "$LOGO_PNG" ]]; then
        cp "$LOGO_PNG" "$PLYMOUTH_DST/logo.png"
    fi
    if [[ -f "$PLYMOUTH_DST/logo.png" ]]; then
        plymouth-set-default-theme -R bangla-os 2>/dev/null || {
            mkdir -p /etc/plymouth
            echo '[Daemon]' > /etc/plymouth/plymouthd.conf
            echo 'Theme=bangla-os' >> /etc/plymouth/plymouthd.conf
            update-initramfs -u 2>/dev/null || true
        }
        log "Plymouth theme: bangla-os"
    fi
fi

# GRUB theme (installed systems)
if [[ -d "$GRUB_SRC" ]]; then
    install -d "$GRUB_DST"
    cp "$GRUB_SRC/theme.txt" "$GRUB_DST/"
    [[ -f "$PROJECT_ROOT/assets/branding/grub/background.png" ]] && \
        cp "$PROJECT_ROOT/assets/branding/grub/background.png" "$GRUB_DST/"
    if [[ -f /etc/default/grub ]]; then
        if grep -q '^GRUB_THEME=' /etc/default/grub; then
            sed -i 's|^GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/bangla-os/theme.txt"|' /etc/default/grub
        else
            echo 'GRUB_THEME="/boot/grub/themes/bangla-os/theme.txt"' >> /etc/default/grub
        fi
        update-grub 2>/dev/null || true
        log "GRUB theme installed at $GRUB_DST"
    fi
fi

log "Boot branding applied."
