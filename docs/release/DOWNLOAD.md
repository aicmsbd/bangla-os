# Bangla OS — Download

**Recommended:** `bangla-os-1.0-amd64-patched.iso` (2.3 GB)

## Latest release

| Version | Link |
|---------|------|
| **v1.0.1** (branding refresh) | [GitHub Release](https://github.com/aicmsbd/bangla-os/releases/tag/v1.0.1) |
| v1.0.0 | [GitHub Release](https://github.com/aicmsbd/bangla-os/releases/tag/v1.0.0) |

## Verify SHA256 (v1.0.1 patched ISO)

```
bc8283d81a4037db06e070d835c1a31e4a82178c44904cc15b077dc9432fc535  bangla-os-1.0-amd64-patched.iso
```

Windows PowerShell:

```powershell
Get-FileHash .\bangla-os-1.0-amd64-patched.iso -Algorithm SHA256
```

## Get the ISO

| Source | Notes |
|--------|--------|
| [GitHub Release v1.0.1](https://github.com/aicmsbd/bangla-os/releases/tag/v1.0.1) | SHA256SUMS + torrent (ISO > 2 GB GitHub limit) |
| BitTorrent | `bangla-os-1.0-amd64-patched.iso.torrent` on release or in `output/` |
| Build yourself | `scripts/host/create-all-versions.ps1` + QEMU build VM |

## Live session

- User: `live`
- Password: `evolution`

## Boot test (QEMU, 8 GB RAM)

```powershell
.\scripts\host\boot-qemu-test.ps1
```

## SourceForge (planned)

Maintainers: upload patched ISO + SHA256SUMS to SourceForge and add mirror URL here.
