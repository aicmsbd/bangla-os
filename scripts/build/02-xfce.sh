#!/bin/bash
# Phase 1.3: XFCE minimal desktop
# [E:MIX-3] Decision: --no-install-recommends + manual UX packages
set -euo pipefail
source "$(dirname "$0")/00-common.sh"
require_root

log "Phase 1.3 — XFCE minimal install"

apt_install \
    xfce4 xfce4-goodies xfce4-terminal thunar thunar-volman \
    lightdm lightdm-gtk-greeter \
    network-manager network-manager-gnome \
    pulseaudio pavucontrol \
    bluez blueman \
    file-roller p7zip-full unrar-free \
    fonts-noto fonts-noto-core fonts-noto-ui-core \
    dbus-x11 xdg-utils

# Debian netinst may install gdm3 first; switch to lightdm for XFCE
if [[ -L /etc/systemd/system/display-manager.service ]]; then
    rm -f /etc/systemd/system/display-manager.service
fi
systemctl enable lightdm
systemctl disable --now bluetooth.service 2>/dev/null || true

log "XFCE installed. Reboot and verify GUI (target idle RAM < 500MB)."
