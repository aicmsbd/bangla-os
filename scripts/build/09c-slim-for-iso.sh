#!/bin/bash
# Slim installed system before eggs produce (reduce ISO size)
set -euo pipefail
source "$(dirname "$0")/00-common.sh"
require_root

log "Pre-ISO slim — removing caches and optional heavy packages"

# Flatpak/Bottles pull large runtimes; Wine via apt is enough for v1.0 live ISO
if command -v flatpak &>/dev/null; then
    flatpak uninstall -y com.usebottles.bottles 2>/dev/null || true
    flatpak uninstall --unused -y 2>/dev/null || true
    rm -rf /var/lib/flatpak/app /var/lib/flatpak/runtime 2>/dev/null || true
fi

# eggs/yolk cached debs
rm -rf /var/local/yolk/* 2>/dev/null || true

# Build VM-only tools not needed on live ISO
apt-get remove -y --purge virtualbox-guest-utils virtualbox-guest-x11 2>/dev/null || true
rm -rf /opt/VBoxGuestAdditions-* 2>/dev/null || true

# Docs and locales (keep en + bn)
apt-get remove -y --purge $(dpkg-query -Wf '${Package}\n' 'linux-doc-*' 2>/dev/null) 2>/dev/null || true
find /usr/share/doc -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} + 2>/dev/null || true
find /usr/share/man -name '*.gz' -delete 2>/dev/null || true

apt-get autoremove -y --purge
apt-get clean
rm -rf /var/cache/apt/archives/* /tmp/* /root/.cache/* 2>/dev/null || true

log "Pre-ISO slim complete. df -h /:"
df -h /
