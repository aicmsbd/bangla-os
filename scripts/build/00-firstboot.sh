#!/bin/bash
# First-boot setup — run once after Debian unattended install completes
set -euo pipefail

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo "Run as root: sudo bash $0"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get install -y openssh-server sudo git

if id banglaos &>/dev/null; then
    usermod -aG sudo banglaos
    usermod -aG vboxsf banglaos 2>/dev/null || true
fi

systemctl enable ssh
systemctl start ssh

mkdir -p /mnt/bangla-os
if ! mountpoint -q /mnt/bangla-os 2>/dev/null; then
    mount -t vboxsf bangla-os /mnt/bangla-os 2>/dev/null || true
fi

echo "First-boot setup complete."
echo "SSH enabled. Shared folder: /mnt/bangla-os"
