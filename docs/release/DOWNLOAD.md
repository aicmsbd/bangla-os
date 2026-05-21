# Bangla OS 1.0 — Download

**Recommended file:** `bangla-os-1.0-amd64-patched.iso` (2.3 GB)

## Verify SHA256

```
a58bd9ee88951c6df74f7fb92579309311d4e902c91728150c31bcd20e39e99e  bangla-os-1.0-amd64-patched.iso
```

Windows PowerShell:

```powershell
Get-FileHash .\bangla-os-1.0-amd64-patched.iso -Algorithm SHA256
```

## Get the ISO

| Source | Notes |
|--------|--------|
| [GitHub Release v1.0.0](https://github.com/aicmsbd/bangla-os/releases/tag/v1.0.0) | Checksums only (ISO > GitHub 2 GB limit) |
| Torrent | `bangla-os-1.0-amd64-patched.iso.torrent` in `output/` after running `scripts/host/create-torrent.ps1` |
| Build yourself | `scripts/host/create-all-versions.ps1` on Windows + QEMU build VM |

## Live session

- User: `live`
- Password: `evolution`

## Boot test (QEMU)

```powershell
.\scripts\host\boot-qemu-test.ps1
```

## Upload to SourceForge (maintainers)

1. Create project at https://sourceforge.net/create/
2. Upload `bangla-os-1.0-amd64-patched.iso` + `SHA256SUMS`
3. Add download URL to GitHub release notes
