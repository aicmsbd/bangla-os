# Bangla OS — Build notes

## VM Snapshots (recommended order)

| Snapshot | After |
|----------|-------|
| 01-base-debian | Minimal Debian install |
| 02-base-tools | Phase 1.2 complete |
| 03-xfce-minimal | Phase 1.3 + GUI verified |
| 04-bengali-support | Phase 1.4 |
| 05-wine-ready | Phase 1.5 |
| 06-essential-apps | Phase 1.6 |
| 07-windows-look | Phase 1.7 |
| 08-branding-basic | Phase 1.8 |
| 09-eggs-installed | Phase 1.9 |

Create snapshot (VirtualBox GUI or):

```powershell
VBoxManage snapshot "BanglaOS-Build" take "03-xfce-minimal" --description "After XFCE install"
```

## Host credentials

- VM name: `BanglaOS-Build`
- User: `banglaos` / `banglaos`
- Root/sudo: `banglaos`

## Copy ISO from VM to host

After build, from PowerShell on host:

```powershell
VBoxManage guestcontrol BanglaOS-Build copyto --target "C:\Users\Z\Desktop\Bangla OS\output\" --username banglaos --password banglaos /home/eggs/*.iso
```

Or use shared folder `/mnt/bangla-os` after Guest Additions mount.
