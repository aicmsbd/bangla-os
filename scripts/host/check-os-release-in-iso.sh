#!/bin/bash
# Quick extract PRETTY_NAME from ISO squashfs
set -euo pipefail
ISO="${1:-/mnt/c/Users/Z/Desktop/Bangla OS/output/bangla-os-1.0-amd64-patched.iso}"
WORK="/tmp/bo-osrel-$$"
mkdir -p "$WORK"
trap 'rm -rf "$WORK"' EXIT
xorriso -osirrox on -indev "$ISO" -extract /live/filesystem.squashfs "$WORK/fs.sqfs" 2>/dev/null
unsquashfs -f -d "$WORK/root" "$WORK/fs.sqfs" usr/lib/os-release etc/os-release >/dev/null 2>&1 || true
OSR="$WORK/root/usr/lib/os-release"
[[ -f "$OSR" ]] || OSR="$WORK/root/etc/os-release"
[[ -f "$OSR" ]] || { echo "os-release not found" >&2; exit 1; }
echo "[os-release]"
grep -E 'PRETTY_NAME|VERSION_ID' "$OSR"
