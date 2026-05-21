#!/bin/bash
# Common helpers for Bangla OS build scripts
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export LANG=en_US.UTF-8

log() { echo "[bangla-os] $*"; }
require_root() {
    if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
        echo "Run as root: sudo $0" >&2
        exit 1
    fi
}

apt_update() {
    log "Updating package lists..."
    apt-get update -qq
}

apt_install() {
    apt-get install -y --no-install-recommends "$@"
}

apt_upgrade() {
    log "Upgrading system..."
    apt-get upgrade -y -qq
}

enable_contrib_nonfree() {
    if grep -E '^deb ' /etc/apt/sources.list | grep -q 'contrib'; then
        return 0
    fi
    log "Enabling contrib and non-free repositories..."
    sed -i -E 's/(^deb .* bookworm(-security|-updates)? main)( non-free-firmware)?/\1 contrib non-free non-free-firmware/g' /etc/apt/sources.list
    apt_update
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
