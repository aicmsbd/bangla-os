#!/bin/bash
# Generate boot splash PNGs for GRUB/isolinux (640x480) from logo
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOGO="$PROJECT_ROOT/assets/branding/png/bangla-os-256.png"
SVG="$PROJECT_ROOT/assets/branding/logo.svg"
SPLASH="$PROJECT_ROOT/assets/branding/eggs-theme/livecd/splash.png"
GRUB_BG="$PROJECT_ROOT/assets/branding/grub/background.png"

if [[ ! -f "$LOGO" && -f "$SVG" ]]; then
    if command -v rsvg-convert &>/dev/null; then
        mkdir -p "$(dirname "$LOGO")"
        rsvg-convert -w 256 -h 256 "$SVG" -o "$LOGO"
    fi
fi

install -d "$(dirname "$SPLASH")" "$(dirname "$GRUB_BG")"

if command -v convert &>/dev/null && [[ -f "$LOGO" ]]; then
    convert -size 640x480 "xc:#006a4e" \
        \( "$LOGO" -resize 300x300 \) -gravity center -composite "$SPLASH"
    convert -size 1920x1080 "xc:#006a4e" \
        \( "$LOGO" -resize 420x420 \) -gravity center -composite "$GRUB_BG"
    echo "[boot-splash] Generated $SPLASH and $GRUB_BG"
elif [[ -f "$LOGO" ]]; then
    cp "$LOGO" "$SPLASH"
    cp "$LOGO" "$GRUB_BG"
    echo "[boot-splash] Copied logo as splash (install imagemagick for composite)"
else
    echo "[boot-splash] WARNING: no logo PNG; boot menu may lack splash.png" >&2
fi
