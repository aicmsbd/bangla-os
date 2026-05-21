#!/bin/bash
# Register Bangla OS with penguins-eggs (bookworm derivative)
set -euo pipefail

DERIVATIVES="/usr/local/lib/nodejs/lib/node_modules/penguins-eggs/conf/derivatives.yaml"
[[ -f "$DERIVATIVES" ]] || DERIVATIVES="/usr/lib/penguins-eggs/conf/derivatives.yaml"

if [[ ! -f "$DERIVATIVES" ]]; then
    echo "derivatives.yaml not found" >&2
    exit 1
fi

if ! grep -q 'padma' "$DERIVATIVES" 2>/dev/null; then
    sed -i '/- id: bookworm/,/^- id:/ {
        /ids:/a\    - padma       # Bangla OS 1.0 (Padma)\n    - bangla-os   # Bangla OS
    }' "$DERIVATIVES"
    echo "Registered Bangla OS in $DERIVATIVES"
else
    echo "Bangla OS already registered in derivatives.yaml"
fi

THEME_DIR="$(dirname "$DERIVATIVES")/../addons/eggs/theme/livecd"
THEME_DIR="$(cd "$THEME_DIR" 2>/dev/null && pwd || true)"
if [[ -d "$THEME_DIR" ]]; then
    ln -sf generic.isolinux.theme.cfg "$THEME_DIR/isolinux.theme.cfg"
    ln -sf generic.isolinux.main.cfg "$THEME_DIR/isolinux.main.cfg"
    ln -sf generic.grub.theme.cfg "$THEME_DIR/grub.theme.cfg"
    ln -sf generic.grub.main.cfg "$THEME_DIR/grub.main.cfg"
    echo "Theme symlinks OK in $THEME_DIR"
fi
