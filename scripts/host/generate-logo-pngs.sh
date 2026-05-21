#!/bin/bash
# Generate logo PNGs from assets/branding/logo.svg
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SVG="$ROOT/assets/branding/logo.svg"
OUT="$ROOT/assets/branding/png"
SIZES=(16 22 24 32 48 64 128 256 512)

if [[ ! -f "$SVG" ]]; then
    echo "Missing $SVG" >&2
    exit 1
fi

mkdir -p "$OUT"

render() {
    if command -v rsvg-convert &>/dev/null; then
        rsvg-convert -w "$2" -h "$2" "$1" -o "$3"
    elif command -v inkscape &>/dev/null; then
        inkscape "$1" -w "$2" -h "$2" -o "$3" 2>/dev/null
    elif command -v convert &>/dev/null; then
        convert -background none -resize "${2}x${2}" "$1" "$3"
    else
        echo "Install rsvg-convert, inkscape, or imagemagick in WSL" >&2
        exit 1
    fi
}

if ! command -v rsvg-convert &>/dev/null && ! command -v inkscape &>/dev/null && ! command -v convert &>/dev/null; then
    apt-get update -qq && apt-get install -y -qq librsvg2-bin 2>/dev/null || true
fi

for s in "${SIZES[@]}"; do
    render "$SVG" "$s" "$OUT/bangla-os-${s}.png"
    echo "  $OUT/bangla-os-${s}.png"
done

echo "[logo-png] Done."
