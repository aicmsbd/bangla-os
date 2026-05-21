#!/bin/bash
# Post-process eggs ISO inside build VM (syslinux modules only)
set -euo pipefail
source "$(dirname "$0")/00-common.sh"
require_root

ISO="$(ls -1 /home/eggs/*.iso 2>/dev/null | tail -1)"
[[ -f "$ISO" ]] || { log "No ISO found"; exit 1; }

SYSLINUX_DIR="/usr/lib/syslinux/modules/bios"
apt_install syslinux-common isolinux xorriso

WORK="/tmp/bangla-iso-fix-$$"
mkdir -p "$WORK/isolinux"
xorriso -osirrox on -indev "$ISO" -extract /isolinux/isolinux.cfg "$WORK/isolinux/isolinux.cfg" 2>/dev/null

sed -i 's|^path[[:space:]]*$|path /isolinux/|' "$WORK/isolinux/isolinux.cfg"

for f in vesamenu.c32 ldlinux.c32 libcom32.c32 libutil.c32 chain.c32 menu.c32; do
    [[ -f "$SYSLINUX_DIR/$f" ]] && cp -f "$SYSLINUX_DIR/$f" "$WORK/isolinux/$f"
done

FIXED="${ISO%.iso}-fixed.iso"
MAP_ARGS=(-map "$WORK/isolinux/isolinux.cfg" /isolinux/isolinux.cfg)
for f in vesamenu.c32 ldlinux.c32 libcom32.c32 libutil.c32 chain.c32 menu.c32; do
    [[ -f "$WORK/isolinux/$f" ]] && MAP_ARGS+=(-map "$WORK/isolinux/$f" "/isolinux/$f")
done

xorriso -indev "$ISO" -outdev "$FIXED" -boot_image any replay "${MAP_ARGS[@]}" -commit
rm -rf "$WORK"
mv -f "$FIXED" "$ISO"
log "ISO boot fixed: $ISO"
