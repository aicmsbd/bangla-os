#!/bin/bash
ISO="/mnt/c/Users/Z/Desktop/Bangla OS/output/bangla-os-1.0-amd64-serial.iso"
xorriso -osirrox on -indev "$ISO" -extract /isolinux/isolinux.cfg /tmp/isolinux-serial.cfg 2>/dev/null
grep append /tmp/isolinux-serial.cfg
