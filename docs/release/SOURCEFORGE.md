# SourceForge mirror — Bangla OS ISO

GitHub Releases cannot host the full ISO (2307 MB, near/over practical limits). SourceForge is the recommended **direct download mirror**.

## Prerequisites

1. SourceForge account: https://sourceforge.net/user/registration/
2. Create project: https://sourceforge.net/create/
   - **Name:** `bangla-os` (or `banglaos`)
   - **Title:** Bangla OS
   - **Description:** Bengali-first Debian 12 XFCE live/install ISO
   - **License:** GPL-3.0-or-later
   - **Homepage:** https://github.com/aicmsbd/bangla-os

## Files to upload

From `output/` on the build host:

| File | Purpose |
|------|---------|
| `bangla-os-1.0-amd64-patched.iso` | **Primary download** (bootable) |
| `SHA256SUMS` | Integrity verification |
| `bangla-os-1.0-amd64-patched.iso.torrent` | Optional (also on GitHub) |

Copy checksums from `docs/release/SHA256SUMS` if needed.

## Upload steps (web UI)

1. Project → **Files** → **Add Folder** → e.g. `1.0.1`
2. Upload `bangla-os-1.0-amd64-patched.iso` (may take 30–60+ min)
3. Upload `SHA256SUMS`
4. Set **Default download** to the patched ISO
5. Copy the direct download URL (e.g. `https://sourceforge.net/projects/bangla-os/files/1.0.1/bangla-os-1.0-amd64-patched.iso/download`)

## After upload

1. Add mirror URL to `docs/release/DOWNLOAD.md`
2. Edit GitHub release v1.0.1 notes (or post comment) with SourceForge link
3. Update announcement drafts with mirror URL
4. Optional: `gh release upload v1.0.1` cannot add ISO if >2GB — SourceForge is the mirror

## CLI alternative (optional)

If `rsync` + SourceForge SSH is configured for the project:

```bash
# Example — adjust project path after SF project creation
rsync -avP output/bangla-os-1.0-amd64-patched.iso \
  USER@frs.sourceforge.net:/home/frs/project/bangla-os/1.0.1/
```

See: https://sourceforge.net/p/forge/documentation/Release%20Files%20for%20Download/

## Verify mirror

Users should verify SHA256 after download:

```powershell
Get-FileHash .\bangla-os-1.0-amd64-patched.iso -Algorithm SHA256
# Expected: b0cc3dd8296ac55f31a9d4451edfe5c915deaaeb087bd8201cb153d103e67014
```
