#!/bin/bash
# Verify Bangla OS ISO contents without booting
set -euo pipefail
ISO="${1:-/mnt/c/Users/Z/Desktop/Bangla OS/output/bangla-os-1.0-amd64-patched.iso}"
WORK="/tmp/bangla-iso-verify-$$"
mkdir -p "$WORK"
trap 'sudo rm -rf "$WORK" 2>/dev/null || true' EXIT

echo "[verify-iso] Boot files:"
xorriso -osirrox on -indev "$ISO" -ls /live/ 2>/dev/null
xorriso -osirrox on -indev "$ISO" -ls /isolinux/ 2>/dev/null | grep -E 'c32|isolinux.bin' || true

echo "[verify-iso] Extracting squashfs..."
xorriso -osirrox on -indev "$ISO" -extract /live/filesystem.squashfs "$WORK/fs.sqfs" 2>/dev/null
sudo unsquashfs -d "$WORK/root" -f "$WORK/fs.sqfs" etc usr/lib/os-release usr/bin/neofetch usr/bin/firefox-esr usr/bin/wine usr/bin/ibus-daemon 2>/dev/null || true

OSR=$(find "$WORK/root" -name 'os-release' 2>/dev/null | head -1 || true)
echo "[verify-iso] os-release:"
if [[ -n "$OSR" && -f "$OSR" ]]; then cat "$OSR"; elif [[ -f "$WORK/root/usr/lib/os-release" ]]; then cat "$WORK/root/usr/lib/os-release"; else echo "  MISSING os-release"; fi

echo "[verify-iso] Key packages:"
for b in neofetch firefox-esr wine ibus-daemon openbangla-keyboard calamares calamares-qt; do
  found=$(find "$WORK/root" -name "$b" -type f 2>/dev/null | head -1 || true)
  [[ -n "$found" ]] && echo "  OK $b ($found)" || echo "  MISSING $b"
done

echo "[verify-iso] Squashfs listing (sample):"
unsquashfs -ll "$WORK/fs.sqfs" 2>/dev/null | grep -E 'os-release|neofetch|firefox|wine|calamares|openbangla|lightdm' | head -30 || true

ISO_MB=$(($(stat -c%s "$ISO") / 1024 / 1024))
echo "[verify-iso] ISO size: ${ISO_MB} MB"
echo "[verify-iso] Done."
