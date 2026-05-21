# Boot themes — Plymouth, GRUB, live ISO menu

Bangla OS uses Bangladesh green (`#006a4e`) and Padma branding on boot.

## Assets

| Path | Purpose |
|------|---------|
| `assets/branding/plymouth/` | Plymouth script theme (live + installed) |
| `assets/branding/grub/theme.txt` | GRUB theme for installed systems |
| `assets/branding/eggs-theme/livecd/` | Penguins-eggs isolinux/GRUB menu theme |
| `assets/branding/eggs-theme/livecd/splash.png` | Generated at build (`generate-boot-splash.sh`) |

## Build scripts

| Script | When |
|--------|------|
| `scripts/build/generate-boot-splash.sh` | Creates `splash.png` + GRUB background from logo |
| `scripts/build/07c-boot-branding.sh` | Installs Plymouth + GRUB on build VM |
| `scripts/build/08b-eggs-register.sh` | Copies live ISO menu theme into eggs |

`07-branding.sh` calls `07c-boot-branding.sh` automatically.

## Apply to ISO

Re-run branding + ISO build on the build VM:

```powershell
.\scripts\host\start-qemu-build.ps1          # if VM not running
.\scripts\host\qemu-run-iso-build.ps1        # 07-branding + 09-eggs-build
.\scripts\host\create-all-versions.ps1 -SkipRebuild
```

Or full rebuild:

```powershell
.\scripts\host\create-all-versions.ps1
```

## Verify (offline)

After rebuild, branding in squashfs should include Plymouth/GRUB paths:

```powershell
wsl bash scripts/host/check-branding-in-iso.sh
python scripts/host/qemu-live-test.py
```

## Live test

- **BIOS/QEMU:** isolinux menu should show green Padma splash and "Bangla OS — Padma" title
- **UEFI:** GRUB menu uses same `splash.png`
- **After boot:** Plymouth splash (green + logo) before LightDM

QEMU recommended; VirtualBox may hang at Plymouth.

## Optional: better splash image

On the build VM, install ImageMagick for composited splash:

```bash
sudo apt-get install -y imagemagick
sudo bash /mnt/bangla-os/scripts/build/generate-boot-splash.sh
```
