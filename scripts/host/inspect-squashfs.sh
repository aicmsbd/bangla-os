#!/bin/bash
set -euo pipefail
ISO="/mnt/c/Users/Z/Desktop/Bangla OS/output/bangla-os-1.0-amd64-patched.iso"
WORK="/tmp/bangla-sq-$$"
mkdir -p "$WORK"
trap 'rm -rf "$WORK"' EXIT
xorriso -osirrox on -indev "$ISO" -extract /live/filesystem.squashfs "$WORK/fs.sqfs" 2>/dev/null
unsquashfs -ll "$WORK/fs.sqfs" | grep -E 'os-release|neofetch|firefox|wine|calamares|openbangla|lightdm' || true
