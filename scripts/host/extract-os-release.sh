#!/bin/bash
set -euo pipefail
ISO="/mnt/c/Users/Z/Desktop/Bangla OS/output/bangla-os-1.0-amd64-patched.iso"
WORK="/tmp/bangla-osr-$$"
mkdir -p "$WORK"
trap 'sudo rm -rf "$WORK"' EXIT
xorriso -osirrox on -indev "$ISO" -extract /live/filesystem.squashfs "$WORK/fs.sqfs" 2>/dev/null
sudo unsquashfs -d "$WORK/root" -f "$WORK/fs.sqfs" usr/lib/os-release 2>/dev/null
echo "=== usr/lib/os-release ==="
cat "$WORK/root/usr/lib/os-release"
