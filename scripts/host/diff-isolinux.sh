#!/bin/bash
for iso in "/mnt/c/Users/Z/Desktop/Bangla OS/output/bangla-os-1.0-amd64-patched.iso" "/mnt/c/Users/Z/Desktop/Bangla OS/output/bangla-os-1.0-amd64-serial.iso"; do
  echo "=== $iso ==="
  xorriso -osirrox on -indev "$iso" -extract /isolinux/isolinux.cfg "/tmp/cfg-$(basename "$iso").txt" 2>/dev/null
  cat "/tmp/cfg-$(basename "$iso").txt"
  echo
done
