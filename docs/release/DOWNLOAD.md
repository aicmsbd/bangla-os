# Bangla OS — Download

**Recommended:** `bangla-os-1.0-amd64-patched.iso` (2.3 GB)

## Latest release

| Version | Link |
|---------|------|
| **v1.0.1** (branding refresh) | [GitHub Release](https://github.com/aicmsbd/bangla-os/releases/tag/v1.0.1) |
| v1.0.0 | [GitHub Release](https://github.com/aicmsbd/bangla-os/releases/tag/v1.0.0) |

## Verify SHA256 (v1.0.1 patched ISO)

```
4f0fd5795a39d0a9bfef59c1ee34cc07437cff6dc7fd9b0a40679e42137fb153  bangla-os-1.0-amd64-patched.iso
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

## SourceForge mirror

Run the upload helper (copies ISO + checksums to a bundle, opens SourceForge):

```powershell
.\scripts\host\prepare-sourceforge-upload.ps1
```

Guide: [SOURCEFORGE.md](SOURCEFORGE.md) — add mirror URL here after upload.
