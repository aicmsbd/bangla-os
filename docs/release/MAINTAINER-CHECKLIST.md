# Phase 1.12 — Maintainer release checklist

Use after each ISO rebuild that ships to users.

## Build & verify

- [ ] `.\scripts\host\create-all-versions.ps1` (or rebuild + `-SkipRebuild`)
- [ ] `python scripts\host\qemu-live-test.py` — offline PASS
- [ ] `wsl bash scripts/host/check-os-release-in-iso.sh` — VERSION 1.0.1
- [ ] `wsl bash scripts/host/check-branding-in-iso.sh` — Plymouth, GRUB, neofetch config

## Artifacts

- [ ] `output/bangla-os-1.0-amd64-patched.iso` (bootable)
- [ ] `output/SHA256SUMS` and `docs/release/SHA256SUMS` match
- [ ] `.\scripts\host\create-torrent.ps1`
- [ ] `gh release upload v1.0.1 SHA256SUMS *.torrent --clobber`

## Mirrors & announce

- [ ] `.\scripts\host\prepare-sourceforge-upload.ps1` — upload bundle to SourceForge
- [ ] Update `docs/release/DOWNLOAD.md` with SourceForge URL
- [ ] Post [ANNOUNCEMENT-DRAFTS.md](ANNOUNCEMENT-DRAFTS.md) (Reddit, Bengali groups)
- [ ] Submit [DISTROWATCH-SUBMIT.txt](DISTROWATCH-SUBMIT.txt)

## Live test (manual)

- [ ] `.\scripts\host\boot-qemu-test.ps1` — login `live` / `evolution`
- [ ] [PHASE-1.11-MANUAL-CHECKLIST.md](../testing/PHASE-1.11-MANUAL-CHECKLIST.md)

## Known constraints

- GitHub: no full ISO (>2 GB) — torrent + SourceForge
- QEMU preferred over VirtualBox for live boot
- Stop QEMU before re-patching ISO if file locked (`create-all-versions.ps1` does this)
