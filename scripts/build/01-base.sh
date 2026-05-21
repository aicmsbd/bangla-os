#!/bin/bash
# Phase 1.2: Base system setup
set -euo pipefail
source "$(dirname "$0")/00-common.sh"
require_root

log "Phase 1.2 — Base system setup"
apt_update
apt_upgrade

apt_install sudo build-essential git vim htop curl wget ca-certificates gnupg

# Ensure build user in sudo group
if id banglaos &>/dev/null; then
    usermod -aG sudo banglaos
fi

# Enable SSH
apt_install openssh-server
systemctl enable ssh

log "Base system setup complete."
