# Bangla OS — Announcement drafts (Phase 1.12)

**Latest ISO:** v1.0.1 boot-themes rebuild (`2026-05-21_1202`)  
**Patched SHA256:** `b0cc3dd8296ac55f31a9d4451edfe5c915deaaeb087bd8201cb153d103e67014`

---

## Reddit r/linux (English)

**Title:** [Release] Bangla OS 1.0.1 (Padma) — Bengali-first Debian 12 + XFCE with full branding

**Body:**

We shipped **Bangla OS 1.0.1**, a Bengali-first Debian 12 Bookworm live/install ISO.

**What's in 1.0.1**
- Padma wallpaper, logo icons, Calamares installer theme
- **Plymouth + GRUB boot themes** (Bangladesh green splash)
- **Live ISO boot menu** with custom splash
- OpenBangla, Firefox ESR, Wine, Calamares
- ~2.3 GB slim ISO

**Download:** https://github.com/aicmsbd/bangla-os/releases/tag/v1.0.1  
BitTorrent + SHA256 on the release. Full ISO is not on GitHub (2 GB limit) — use **torrent** or build from source.

**Live:** `live` / `evolution`  
**Test with:** QEMU (8 GB RAM). VirtualBox may hang at Plymouth.

Issues: https://github.com/aicmsbd/bangla-os/issues

---

## Reddit r/debian (optional)

**Title:** Bangla OS 1.0.1 — Debian 12 Bookworm derivative, Bengali-first XFCE

Debian 12 + XFCE, OpenBangla, Calamares, Wine. Built with Penguins-eggs. Custom Plymouth/GRUB branding.  
https://github.com/aicmsbd/bangla-os/releases/tag/v1.0.1

---

## DistroWatch

Full form text: [DISTROWATCH-SUBMIT.txt](DISTROWATCH-SUBMIT.txt)  
Submit: https://distrowatch.com/dwres.php?resource=submit

---

## বাংলা (Facebook / Telegram / Linux Bangladesh)

**Bangla OS 1.0.1 (Padma)** — Debian 12 ভিত্তিক বাংলা-প্রথম Linux।

**নতুন:** পদ্মা ওয়ালপেপার, Plymouth/GRUB বুট থিম, Calamares ব্র্যান্ডিং। ISO ~২.৩ GB।

- OpenBangla, Firefox, Wine, Calamares
- লাইভ: `live` / `evolution`

**ডাউনলোড:** https://github.com/aicmsbd/bangla-os/releases/tag/v1.0.1  
(Torrent + SHA256 — GitHub-এ পূর্ণ ISO নেই)

---

## Posting checklist

- [ ] SourceForge mirror — run `.\scripts\host\prepare-sourceforge-upload.ps1`
- [ ] r/linux — v1.0.1 post (copy above)
- [ ] r/debian — optional
- [ ] DistroWatch — paste DISTROWATCH-SUBMIT.txt
- [ ] Bengali Linux / tech groups
- [ ] Add SourceForge URL to DOWNLOAD.md after upload
