# ISO Size Reduction Plan (3.5 GB → target <1.5 GB)

Current breakdown driver: **Flatpak + Bottles + GNOME Platform runtime** bundled by `scripts/build/04-wine.sh`.

## Quick wins (Phase 1.x patch)

1. **Remove Bottles from ISO build** — install via Flatpak post-install doc instead  
   Edit `04-wine.sh`: drop `flatpak install com.usebottles.bottles` or move to optional `04b-flatpak-optional.sh`

2. **Exclude Flatpak runtimes from eggs produce**  
   - `eggs.yaml`: review `excludes` / `includes`  
   - Or purge before produce: `flatpak uninstall --unused -y`

3. **eggs compression** — already `fast (zstd)`; try `eggs produce` with max compression if time allows

4. **Remove duplicate kernels** — `09-eggs-build.sh` already removes linux-image-35; verify only one kernel in live

5. **Audit packages** — inside build VM:
   ```bash
   dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -rn | head -30
   du -sh /var/lib/flatpak/*
   ```

## Rebuild after changes

```powershell
.\scripts\host\start-qemu-build.ps1
python scripts\host\qemu-ssh.py run "sudo bash /path/to/09-eggs-build.sh"
.\scripts\host\qemu-download-iso.ps1
wsl bash scripts/host/patch-iso.sh
python scripts/host/qemu-live-test.py
```

## Measure

```powershell
wsl bash scripts/host/analyze-iso-size.sh
```
