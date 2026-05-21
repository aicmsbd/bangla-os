#!/bin/bash
# Patch Bangla OS ISO: add missing syslinux modules (eggs omits .c32 files)
set -euo pipefail

ISO_IN="${1:-/mnt/c/Users/Z/Desktop/Bangla OS/output/bangla-os-1.0-amd64.iso}"
ISO_OUT="${2:-/mnt/c/Users/Z/Desktop/Bangla OS/output/bangla-os-1.0-amd64-patched.iso}"
WORK="$(mktemp -d /tmp/bangla-iso-patch-XXXXXX)"
SYSLINUX_DIR="/usr/lib/syslinux/modules/bios"
C32_FILES=(vesamenu.c32 ldlinux.c32 libcom32.c32 libutil.c32 chain.c32 menu.c32)
BOOT_EXTRA="${BANGLA_BOOT_APPEND:-}"

if [[ ! -d "$SYSLINUX_DIR" ]]; then
    apt-get update -qq
    apt-get install -y -qq syslinux-common isolinux xorriso
fi

mkdir -p "$WORK/isolinux"
xorriso -osirrox on -indev "$ISO_IN" -extract /isolinux/isolinux.cfg "$WORK/isolinux/isolinux.cfg" 2>/dev/null

CFG="$WORK/isolinux/isolinux.cfg"
sed -i 's|^path[[:space:]]*$|path /isolinux/|' "$CFG"
if [[ -n "$BOOT_EXTRA" ]]; then
    sed -i "s|append initrd=\\([^ ]*\\) \\(.*\\)|append initrd=\\1 \\2 ${BOOT_EXTRA}|g" "$CFG"
    echo "[patch-iso] Boot append: ${BOOT_EXTRA}"
fi

for f in "${C32_FILES[@]}"; do
    [[ -f "$SYSLINUX_DIR/$f" ]] && cp -f "$SYSLINUX_DIR/$f" "$WORK/isolinux/$f"
done

CLONE="${ISO_OUT}.tmp"
rm -f "$CLONE"
MAP_ARGS=(-map "$CFG" /isolinux/isolinux.cfg)
for f in "${C32_FILES[@]}"; do
    [[ -f "$WORK/isolinux/$f" ]] && MAP_ARGS+=(-map "$WORK/isolinux/$f" "/isolinux/$f")
done

echo "[patch-iso] Cloning ISO..."
xorriso -indev "$ISO_IN" -outdev "$CLONE" -boot_image any replay "${MAP_ARGS[@]}" -commit

# WSL cannot always mv over Windows files (QEMU lock / permission); use host PowerShell
if [[ "$ISO_OUT" == /mnt/c/* ]]; then
    WIN_OUT="${ISO_OUT#/mnt/c/}"
    WIN_OUT="C:/${WIN_OUT//\//\\}"
    WIN_CLONE="${CLONE#/mnt/c/}"
    WIN_CLONE="C:/${WIN_CLONE//\//\\}"
    powershell.exe -NoProfile -Command "Move-Item -Force -LiteralPath '$WIN_CLONE' -Destination '$WIN_OUT'" 2>/dev/null \
        || mv -f "$CLONE" "$ISO_OUT"
else
    mv -f "$CLONE" "$ISO_OUT"
fi
rm -rf "$WORK"

echo "[patch-iso] Done: $ISO_OUT"
ls -lh "$ISO_OUT"
