# Bangla OS 1.0.1 (Padma) — Release Notes

**Release date:** 2026-05-21  
**Codename:** Padma  
**Base:** Debian 12 (Bookworm)  
**Desktop:** XFCE + LightDM

This is a **branding refresh** of Bangla OS 1.0. Same base packages and slim 2.3 GB ISO; Phase 2.1 assets are now baked into the live system.

---

## English

### What's new in 1.0.1

- Padma river default wallpaper (LightDM + `/usr/share/backgrounds/bangla-os/`)
- Bangla OS logo icons (16–512 px)
- Calamares installer branding (`bangla-os` theme)
- Slim ISO retained (~2.3 GB vs 3.5 GB in early 1.0 builds)

### Download

**Recommended:** `bangla-os-1.0-amd64-patched.iso` (2.3 GB)

| File | SHA256 |
|------|--------|
| `bangla-os-1.0-amd64-patched.iso` | `bc8283d81a4037db06e070d835c1a31e4a82178c44904cc15b077dc9432fc535` |
| `bangla-os-1.0-amd64.iso` | `c9435bf71aa86bad6c1d6e5a499b25f2a50616d06490795c89972989fb6ac64c` |

Full list: `SHA256SUMS` on this release.  
**BitTorrent:** `bangla-os-1.0-amd64-patched.iso.torrent`

GitHub file limit is 2 GB — ISO is not attached directly. Use torrent or build from source (`scripts/host/create-all-versions.ps1`).

**Live login:** `live` / `evolution`

### Boot testing

QEMU recommended (8 GB RAM):

```powershell
.\scripts\host\boot-qemu-test.ps1
```

### Known issues

- VirtualBox may hang at Plymouth; use QEMU
- Headless serial boot fails (GUI patched ISO works)
- `os-release` still reports `1.0` until next full version bump rebuild

---

## বাংলা

### ১.০.১-এ নতুন

- পদ্মা থিম ওয়ালপেপার ও LightDM ব্যাকগ্রাউন্ড
- Bangla OS লোগো ও Calamares ইনস্টলার ব্র্যান্ডিং
- ISO আকার ~২.৩ GB

**ডাউনলোড:** `bangla-os-1.0-amd64-patched.iso`  
**লাইভ লগইন:** `live` / `evolution`

---

## Build

- Penguins-eggs, kernel 6.1.0-48-amd64
- Rebuild: `scripts/host/rebuild-v1.0.1.ps1`
