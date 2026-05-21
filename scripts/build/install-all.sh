#!/bin/bash
# Master installer — runs all Phase 1 build scripts in order
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo "Run: sudo bash $0"
    exit 1
fi

scripts=(
    01-base.sh
    02-xfce.sh
    03-bengali.sh
    04-wine.sh
    05-apps.sh
    06-theme.sh
    07-branding.sh
    08-eggs-install.sh
)

for s in "${scripts[@]}"; do
    echo ""
    echo "=========================================="
    echo " Running $s"
    echo "=========================================="
    bash "$SCRIPT_DIR/$s"
done

echo ""
echo "=========================================="
echo " Bangla OS build environment ready."
echo " Reboot, verify desktop, then run:"
echo "   sudo bash scripts/build/09-eggs-build.sh"
echo "=========================================="
