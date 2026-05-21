#!/bin/bash
# Register Bangla OS with penguins-eggs (bookworm derivative)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

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
BANGLA_LIVECD="$PROJECT_ROOT/assets/branding/eggs-theme/livecd"

if [[ -d "$THEME_DIR" ]]; then
    if [[ -d "$BANGLA_LIVECD" && -f "$BANGLA_LIVECD/bangla-os.grub.theme.cfg" ]]; then
        bash "$SCRIPT_DIR/generate-boot-splash.sh" 2>/dev/null || true
        cp -f "$BANGLA_LIVECD/bangla-os.grub.theme.cfg" "$THEME_DIR/grub.theme.cfg"
        cp -f "$BANGLA_LIVECD/bangla-os.isolinux.theme.cfg" "$THEME_DIR/isolinux.theme.cfg"
        [[ -f "$BANGLA_LIVECD/splash.png" ]] && cp -f "$BANGLA_LIVECD/splash.png" "$THEME_DIR/splash.png"
        ln -sf generic.grub.main.cfg "$THEME_DIR/grub.main.cfg"
        ln -sf generic.isolinux.main.cfg "$THEME_DIR/isolinux.main.cfg"
        echo "Bangla OS livecd boot theme in $THEME_DIR"
    else
        ln -sf generic.isolinux.theme.cfg "$THEME_DIR/isolinux.theme.cfg"
        ln -sf generic.isolinux.main.cfg "$THEME_DIR/isolinux.main.cfg"
        ln -sf generic.grub.theme.cfg "$THEME_DIR/grub.theme.cfg"
        ln -sf generic.grub.main.cfg "$THEME_DIR/grub.main.cfg"
        echo "Theme symlinks OK in $THEME_DIR (generic fallback)"
    fi
fi
