# Phase 1.11 — Manual GUI checklist

Run after booting the patched ISO:

```powershell
.\scripts\host\boot-qemu-test.ps1          # 8 GB (default)
.\scripts\host\boot-qemu-test-1gb.ps1      # 1 GB weak-PC test
```

**Login:** `live` / `evolution`

Mark each item PASS / FAIL / SKIP and note bugs at the bottom.

---

## Login & desktop

| # | Check | Result | Notes |
|---|--------|--------|-------|
| 1 | LightDM greeter shows Padma wallpaper | | |
| 2 | Login with live/evolution succeeds | | |
| 3 | XFCE desktop loads (panel, menu) | | |
| 4 | Default wallpaper visible on desktop | | |

## Branding

| # | Check | Result | Notes |
|---|--------|--------|-------|
| 5 | `neofetch` shows Bangla OS 1.0.1 (Padma) | | green color scheme |
| 6 | Menu / about shows Bangla OS branding | | |

## Bengali & apps

| # | Check | Result | Notes |
|---|--------|--------|-------|
| 7 | Super+Space switches to Bengali (OpenBangla) | | |
| 8 | Type Bengali in terminal or mousepad | | |
| 9 | Firefox opens; Bengali text renders | | |
| 10 | Calamares installer launches from menu | | |
| 11 | Calamares shows bangla-os branding | | |
| 12 | `wine --version` in terminal | | |

## Performance

| # | Check | Result | Notes |
|---|--------|--------|-------|
| 13 | `free -h` idle RAM < 500 MB (8 GB VM) | | |
| 14 | 1 GB RAM boot test (separate script) | | |

---

## Bugs found

```
YYYY-MM-DD (critical|major|minor) description
```

Copy results to `output/PHASE-1.11-TEST-RESULTS.md` when done.
