#Requires -Version 5.1
<#
.SYNOPSIS
  Rebuild (optional) and create all Bangla OS 1.0 release ISO variants + checksums.

.OUTPUTS
  output/bangla-os-1.0-amd64.iso           — raw eggs ISO
  output/bangla-os-1.0-amd64-patched.iso   — bootable (syslinux .c32)
  output/bangla-os-1.0-amd64-serial.iso    — serial console boot params (debug)
  output/SHA256SUMS
  output/RELEASE-MANIFEST.txt
#>
param(
    [switch]$SkipRebuild,
    [switch]$SkipSerial,
    [int]$MonitorMinutes = 90
)
$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$Py = Join-Path $ProjectRoot "scripts\host\qemu-ssh.py"
$PatchSh = "/mnt/c/Users/Z/Desktop/Bangla OS/scripts/host/patch-iso.sh"
$OutDir = Join-Path $ProjectRoot "output"
$Version = "1.0"
$Base = "bangla-os-$Version-amd64"
$IsoRaw = Join-Path $OutDir "$Base.iso"
$IsoPatched = Join-Path $OutDir "$Base-patched.iso"
$IsoSerial = Join-Path $OutDir "$Base-serial.iso"

function Invoke-Ssh([string]$Cmd, [switch]$Sudo) {
    $a = @($Py, $(if ($Sudo) { "sudo" } else { "run" }), $Cmd)
    & python @a 2>&1 | Out-String
}

function Wait-Ssh {
    $deadline = (Get-Date).AddMinutes(5)
    while ((Get-Date) -lt $deadline) {
        try {
            $o = Invoke-Ssh "echo ready"
            if ($o -match "ready") { return }
        } catch {}
        Start-Sleep -Seconds 5
    }
    throw "Build VM SSH not ready on port 2222. Run: scripts/host/start-qemu-build.ps1"
}

function Upload-Scripts {
    $tar = Join-Path $env:TEMP "bangla-os-scripts.tar"
    Push-Location $ProjectRoot
    tar -cf $tar scripts config VERSION 2>$null
    Pop-Location
    & python $Py upload $tar "/tmp/bangla-os-scripts.tar" | Out-Null
    Invoke-Ssh "mkdir -p /mnt/bangla-os" -Sudo | Out-Null
    Invoke-Ssh "tar -xf /tmp/bangla-os-scripts.tar -C /mnt/bangla-os" -Sudo | Out-Null
    Write-Host "[all-versions] Scripts uploaded to build VM."
}

function Start-IsoRebuild {
    Invoke-Ssh "nohup bash /mnt/bangla-os/scripts/build/09-eggs-build.sh > /var/log/bangla-iso-rebuild.log 2>&1 & echo STARTED" -Sudo
    Write-Host "[all-versions] ISO rebuild started (log: /var/log/bangla-iso-rebuild.log)"
}

function Wait-IsoRebuild {
    $deadline = (Get-Date).AddMinutes($MonitorMinutes)
    while ((Get-Date) -lt $deadline) {
        $tail = Invoke-Ssh "tail -8 /var/log/bangla-iso-rebuild.log 2>/dev/null" -Sudo
        if ($tail -match "ISO build complete") {
            Write-Host "[all-versions] Build finished."
            return
        }
        Write-Host "[all-versions] Building... $(Get-Date -Format 'HH:mm:ss')"
        Start-Sleep -Seconds 45
    }
    throw "ISO rebuild timed out after $MonitorMinutes minutes."
}

function Download-RawIso {
    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
    $dl = Join-Path $ProjectRoot "scripts\host\qemu-download-iso.py"
    & python $dl $IsoRaw
    if (-not (Test-Path $IsoRaw)) { throw "ISO download failed: $IsoRaw" }
    Write-Host "[all-versions] Downloaded $IsoRaw ($([math]::Round((Get-Item $IsoRaw).Length/1MB)) MB)"
}

function Patch-Isos {
    # Stop GUI QEMU if it locks the patched ISO on Windows
    Get-Process qemu-system-x86_64 -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    Write-Host "[all-versions] Patching bootable ISO..."
    wsl bash $PatchSh `
        "/mnt/c/Users/Z/Desktop/Bangla OS/output/$Base.iso" `
        "/mnt/c/Users/Z/Desktop/Bangla OS/output/$Base-patched.iso"
    if (-not $SkipSerial) {
        Write-Host "[all-versions] Creating serial-console ISO..."
        wsl bash -lc "BANGLA_BOOT_APPEND='console=ttyS0,115200n8' bash '$PatchSh' '/mnt/c/Users/Z/Desktop/Bangla OS/output/$Base-patched.iso' '/mnt/c/Users/Z/Desktop/Bangla OS/output/$Base-serial.iso'"
    }
}

function Write-Checksums {
    Push-Location $OutDir
    $files = @("$Base.iso", "$Base-patched.iso")
    if (-not $SkipSerial -and (Test-Path "$Base-serial.iso")) { $files += "$Base-serial.iso" }
    $lines = foreach ($f in $files) {
        if (Test-Path $f) {
            $h = (Get-FileHash $f -Algorithm SHA256).Hash.ToLower()
            "$h  $f"
        }
    }
    $lines | Set-Content -Encoding ascii "SHA256SUMS"
    Pop-Location
    Write-Host "[all-versions] SHA256SUMS written."
}

function Write-Manifest {
    $manifest = Join-Path $OutDir "RELEASE-MANIFEST.txt"
    @"
Bangla OS $Version (Padma) — Release artifacts
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

Files:
  $Base.iso          — raw penguins-eggs output
  $Base-patched.iso  — recommended for boot (QEMU/VirtualBox)
  $Base-serial.iso   — serial console kernel params (debug only)

Live login: live / evolution
Verify: python scripts/host/qemu-live-test.py
Boot test: .\scripts\host\boot-qemu-test.ps1

See RELEASE-NOTES-1.0.md and SHA256SUMS.
"@ | Set-Content -Encoding utf8 $manifest
}

Wait-Ssh
Upload-Scripts

if (-not $SkipRebuild) {
    Start-IsoRebuild
    Wait-IsoRebuild
} else {
    Write-Host "[all-versions] Skipping rebuild (-SkipRebuild)."
}

Download-RawIso
Patch-Isos
Write-Checksums
Write-Manifest

Write-Host ""
Write-Host "=== All versions ready in output/ ==="
Get-ChildItem $OutDir -Filter "bangla-os-1.0*" | Format-Table Name, @{N='MB';E={[math]::Round($_.Length/1MB)}} -AutoSize
Get-Content (Join-Path $OutDir "SHA256SUMS")
