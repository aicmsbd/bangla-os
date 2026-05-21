#!/bin/bash
# Phase 1.10: First ISO build with Penguins-eggs
set -euo pipefail
source "$(dirname "$0")/00-common.sh"
require_root

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log "Phase 1.10 — ISO build"

# Ensure eggs is on PATH
ln -sf /usr/local/lib/nodejs/bin/eggs /usr/local/bin/eggs 2>/dev/null || true

# Register Bangla OS as Debian bookworm derivative (also fixes theme symlinks)
bash "$SCRIPT_DIR/08b-eggs-register.sh"
eggs dad -d -n 2>/dev/null || eggs dad -c -n 2>/dev/null || true

FREE_GB=$(df -BG / | awk 'NR==2 {gsub(/G/,"",$4); print $4}')
if [[ "${FREE_GB:-0}" -lt 10 ]]; then
    log "WARNING: Less than 10 GB free on /. ISO build may fail."
fi

apt-get autoremove -y --purge
apt-get clean

# Ensure one kernel + matching initramfs before ISO build (fixes live boot hang/panic)
apt-get remove -y 'linux-image-6.1.0-35-amd64' 2>/dev/null || true
apt_install linux-image-amd64
KVER="$(uname -r)"
update-initramfs -u -k "$KVER"

# Calamares + ISO tooling required by eggs produce
apt_install calamares calamares-settings-debian \
    squashfs-tools xorriso syslinux isolinux genisoimage

# Configure eggs
CONFIG="/etc/penguins-eggs.d/eggs.yaml"
if [[ ! -f "$CONFIG" ]]; then
    eggs dad -n 2>/dev/null || true
fi

if [[ -f "$CONFIG" ]]; then
    sed -i 's/^basename:.*/basename: bangla-os/' "$CONFIG" 2>/dev/null || true
    sed -i 's/^version:.*/version: "1.0"/' "$CONFIG" 2>/dev/null || true
fi

bash "$SCRIPT_DIR/09c-slim-for-iso.sh"

log "Starting eggs produce (this takes 20-60 minutes)..."
eggs produce --release --basename=bangla-os --verbose --nointeractive

bash "$SCRIPT_DIR/09b-fix-iso-boot.sh"

ISO_DIR="/home/eggs"
if [[ -d "$ISO_DIR" ]]; then
    ls -lh "$ISO_DIR"/*.iso 2>/dev/null || ls -lh "$ISO_DIR"/
    for iso in "$ISO_DIR"/*.iso; do
        [[ -f "$iso" ]] || continue
        sha256sum "$iso" | tee "${iso}.sha256"
        log "ISO: $iso"
    done
else
    log "Check eggs output directory for ISO."
fi

log "ISO build complete."
