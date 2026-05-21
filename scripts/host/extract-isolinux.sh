#!/bin/bash
set -euo pipefail
ISO="/mnt/c/Users/Z/Desktop/Bangla OS/output/bangla-os-1.0-amd64-patched.iso"
xorriso -osirrox on -indev "$ISO" -extract /isolinux/isolinux.cfg /tmp/isolinux.cfg 2>/dev/null
cat /tmp/isolinux.cfg
