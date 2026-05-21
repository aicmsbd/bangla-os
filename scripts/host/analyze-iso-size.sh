#!/bin/bash
set -euo pipefail
ISO="/mnt/c/Users/Z/Desktop/Bangla OS/output/bangla-os-1.0-amd64-patched.iso"
WORK="/tmp/bangla-dirs-$$"
mkdir -p "$WORK"
trap 'rm -rf "$WORK"' EXIT
xorriso -osirrox on -indev "$ISO" -extract /live/filesystem.squashfs "$WORK/fs.sqfs" 2>/dev/null
echo "[dirs] squashfs compressed: $(du -h "$WORK/fs.sqfs" | cut -f1)"
echo "[dirs] By path prefix (file bytes in listing):"
unsquashfs -ll "$WORK/fs.sqfs" 2>/dev/null | awk '
$1 ~ /^-/ {
  for(i=1;i<=NF;i++) if($i ~ /squashfs-root\//) { p=$i; break }
  sub(/.*squashfs-root\//,"",p)
  if(p ~ /^var\/lib\/flatpak\//) k="var/lib/flatpak"
  else if(p ~ /^var\/local\/yolk\//) k="var/local/yolk (eggs cache)"
  else if(p ~ /^usr\/local\/lib\/nodejs\//) k="usr/local/lib/nodejs (eggs/npm)"
  else if(p ~ /^usr\/share\/doc\//) k="usr/share/doc"
  else if(p ~ /^usr\/lib\/firefox\//) k="usr/lib/firefox"
  else if(p ~ /^usr\/lib\/wine\//) k="usr/lib/wine"
  else { split(p,a,"/"); k=a[1]"/"a[2] }
  sum[k]+=$5
}
END { for(k in sum) printf "%14d MB  %s\n", int(sum[k]/1024/1024), k }' | sort -rn | head -20
