#!/bin/bash
set -euo pipefail
ISO="${1:-/mnt/c/Users/Z/Desktop/Bangla OS/output/bangla-os-1.0-amd64-patched.iso}"
WORK="/tmp/bo-brand-$$"
mkdir -p "$WORK"
trap 'rm -rf "$WORK"' EXIT
xorriso -osirrox on -indev "$ISO" -extract /live/filesystem.squashfs "$WORK/fs.sqfs" 2>/dev/null
echo "[branding] wallpaper / logo / calamares:"
unsquashfs -ll "$WORK/fs.sqfs" 2>/dev/null | grep -E 'bangla-os|backgrounds/bangla|calamares/branding/bangla' | head -25
