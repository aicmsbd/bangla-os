#!/bin/bash
set -euo pipefail
ISO="/mnt/c/Users/Z/Desktop/Bangla OS/output/bangla-os-1.0-amd64-patched.iso"
WORK="/tmp/bangla-flatpak-$$"
mkdir -p "$WORK"
trap 'rm -rf "$WORK"' EXIT
xorriso -osirrox on -indev "$ISO" -extract /live/filesystem.squashfs "$WORK/fs.sqfs" 2>/dev/null
echo "squashfs: $(du -h "$WORK/fs.sqfs" | cut -f1)"
echo "flatpak runtime/app sizes:"
unsquashfs -ll "$WORK/fs.sqfs" 2>/dev/null | grep -E 'squashfs-root/var/lib/flatpak/(runtime|app)/' | awk '
{
  for(i=1;i<=NF;i++) if($i ~ /squashfs-root/) { path=$i; break }
  sub(/.*squashfs-root\/var\/lib\/flatpak\//,"",path)
  n=split(path,p,"/")
  if(n>=2) key=p[1]"/"p[2]"/"p[3]; else key=path
  if($1 ~ /^-/) sum[key]+=$5
}
END { for(k in sum) printf "%12d  %s\n", sum[k], k }' | sort -rn | head -15
