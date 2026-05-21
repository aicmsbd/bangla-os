#!/bin/bash
# Phase 1.9: Penguins-eggs installation
set -euo pipefail
source "$(dirname "$0")/00-common.sh"
require_root

log "Phase 1.9 — Penguins-eggs"

if command -v eggs &>/dev/null; then
    eggs --version
    log "Penguins-eggs already installed."
    exit 0
fi

apt_install fuse3 libfuse2 ca-certificates curl xz-utils

# Node.js 22 binary (Debian 12 apt only has Node 18; eggs needs >= 22)
if ! command -v node &>/dev/null || ! node --version | grep -qE 'v2[2-9]|v[3-9]'; then
    log "Installing Node.js 22 binary..."
    NODE_VER="22.13.1"
    NODE_DIR="/usr/local/lib/nodejs"
    NODE_TAR="/tmp/node-v${NODE_VER}-linux-x64.tar.xz"
    curl -fsSL "https://nodejs.org/dist/v${NODE_VER}/node-v${NODE_VER}-linux-x64.tar.xz" -o "$NODE_TAR"
    rm -rf "$NODE_DIR"
    mkdir -p "$NODE_DIR"
    tar -xJf "$NODE_TAR" -C "$NODE_DIR" --strip-components=1
    ln -sf "$NODE_DIR/bin/node" /usr/local/bin/node
    ln -sf "$NODE_DIR/bin/npm" /usr/local/bin/npm
    ln -sf "$NODE_DIR/bin/npx" /usr/local/bin/npx
    rm -f "$NODE_TAR"
    node --version
fi

log "Installing penguins-eggs via npm..."
npm install -g penguins-eggs

# Link eggs CLI into PATH
if [[ -x /usr/local/lib/nodejs/bin/eggs ]]; then
    ln -sf /usr/local/lib/nodejs/bin/eggs /usr/local/bin/eggs
fi

eggs --version
log "Penguins-eggs installed. Run 09-eggs-build.sh to produce ISO."
