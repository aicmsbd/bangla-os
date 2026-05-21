# Bangla OS (বাঙলা OS)

**Codename:** Padma (পদ্মা)  
**Version:** 1.0  
**Base:** Debian 12 (Bookworm)  
**Desktop:** XFCE  
**Build Tool:** [Penguins-eggs](https://github.com/pieroproietti/penguins-eggs) (Phase 1)

Bangla OS is a lightweight, Bengali-first Linux distribution designed for Bangladeshi users migrating from Windows. It runs well on older hardware and ships with Bengali typing, Windows-style UX, and Wine support.

## Quick Start (Build Host — Windows)

### Prerequisites

- Windows 10/11 with 8 GB+ RAM and 100 GB+ free disk
- [QEMU](https://www.qemu.org/) (recommended) or VirtualBox 7.x
- Git, PowerShell, WSL (for ISO patching)

### Test the ISO (QEMU — recommended)

```powershell
.\scripts\host\boot-qemu-test.ps1          # 8 GB RAM, GUI
.\scripts\host\boot-qemu-test-1gb.ps1      # 1 GB weak-PC test
python scripts\host\qemu-live-test.py      # offline ISO verify
```

Live login: **live** / **evolution**

ISO files: `output/bangla-os-1.0-amd64-patched.iso` (bootable), checksums in `output/SHA256SUMS`.

### Build VM (QEMU)

VirtualBox build VM may fail with `E_FAIL`; use QEMU instead:

```powershell
.\scripts\host\start-qemu-build.ps1
python scripts\host\qemu-ssh.py run "command"
.\scripts\host\qemu-run-iso-build.ps1      # rebuild ISO via SSH
.\scripts\host\qemu-download-iso.ps1       # copy ISO to output/
wsl bash scripts/host/patch-iso.sh           # add syslinux modules
.\scripts\host\create-all-versions.ps1     # rebuild + all ISO variants + SHA256SUMS
```

SSH: `banglaos@127.0.0.1` port **2222**, password **banglaos**

### Legacy: VirtualBox build VM

```powershell
cd "C:\Users\Z\Desktop\Bangla OS"
.\scripts\host\create-vm.ps1
```

This creates **BanglaOS-Build** (4 GB RAM, 40 GB disk, BIOS boot) and starts unattended Debian 12 installation.

### 2. After Debian installs — run build scripts inside the VM

The shared folder is available at `/mnt/bangla-os` after Guest Additions install.

**From Windows (recommended — no WSL):**

```powershell
.\scripts\host\run-build.ps1
.\scripts\host\build-status.ps1
```

**Or log in to the VM** as `banglaos` / `banglaos`:

```bash
sudo mount -t vboxsf bangla-os /mnt/bangla-os
sudo bash /mnt/bangla-os/scripts/build/install-all.sh
```

SSH from Windows (optional): `ssh -p 2222 banglaos@127.0.0.1`

### 3. Build ISO with Penguins-eggs

```bash
sudo bash scripts/build/09-eggs-build.sh
```

ISO output: `/home/eggs/` on the build VM.

## Project Structure

```
bangla-os/
├── assets/          # Fonts, logos, wallpapers
├── config/          # Preseed, eggs config templates
├── docs/            # Guides (Bengali + English)
├── iso/             # Debian netinst ISO (not in git)
├── scripts/
│   ├── build/       # Run inside Debian VM
│   └── host/        # Run on Windows host
├── vm/              # VM metadata, snapshots notes
└── todo.txt         # Master task list
```

## Build VM Credentials

| Field    | Value     |
|----------|-----------|
| Hostname | bangla-os   |
| User     | banglaos    |
| Password | banglaos    |
| Root     | (set during install) |

## Success Metrics (Phase 1)

- ISO under 1.5 GB
- Idle RAM under 500 MB
- Bengali typing works (OpenBangla + ibus)
- Wine functional
- Calamares installer boots from live ISO

## License

GPL-3.0-or-later — see [LICENSE](LICENSE).

## Links

- [OpenBangla Keyboard](https://github.com/OpenBangla/OpenBangla-Keyboard)
- [Penguins-eggs](https://github.com/pieroproietti/penguins-eggs)
- [Debian 12 netinst](https://www.debian.org/CD/netinst/)
