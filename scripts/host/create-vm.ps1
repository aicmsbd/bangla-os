#Requires -Version 5.1
<#
.SYNOPSIS
    Creates and starts the BanglaOS-Build VirtualBox VM with unattended Debian 12 install.
#>
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$VBoxPath    = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$VmName      = "BanglaOS-Build"
$IsoPath     = Join-Path $ProjectRoot "iso\debian-12.11.0-amd64-netinst.iso"
$VmDir       = Join-Path $ProjectRoot "vm\BanglaOS-Build"
$DiskPath    = Join-Path $VmDir "BanglaOS-Build.vdi"

if (-not (Test-Path $VBoxPath)) {
    throw "VirtualBox not found. Install with: winget install Oracle.VirtualBox"
}
if (-not (Test-Path $IsoPath)) {
    throw "Debian ISO not found at $IsoPath. Run scripts/host/download-iso.ps1 first."
}

New-Item -ItemType Directory -Force -Path $VmDir | Out-Null

$env:Path = "C:\Program Files\Oracle\VirtualBox;" + $env:Path

# Remove existing VM if present
$existing = & $VBoxPath list vms 2>$null | Select-String "`"$VmName`""
if ($existing) {
    Write-Host "Removing existing VM '$VmName'..."
    $ErrorActionPreference = 'SilentlyContinue'
    & $VBoxPath controlvm $VmName poweroff 2>&1 | Out-Null
    $ErrorActionPreference = 'Stop'
    Start-Sleep -Seconds 5
    & $VBoxPath unregistervm $VmName --delete
}

Write-Host "Creating VM '$VmName'..."
& $VBoxPath createvm --name $VmName --ostype "Debian_64" --register --basefolder $VmDir

& $VBoxPath modifyvm $VmName `
    --memory 4096 `
    --vram 128 `
    --cpus 2 `
    --ioapic on `
    --boot1 dvd --boot2 disk --boot3 none --boot4 none `
    --nic1 nat `
    --natpf1 "ssh,tcp,,2222,,22" `
    --audio-driver none `
    --graphicscontroller vboxsvga `
    --firmware bios `
    --rtcuseutc on

& $VBoxPath createmedium disk --filename $DiskPath --size 40960 --format VDI
& $VBoxPath storagectl $VmName --name "SATA" --add sata --controller IntelAhci --portcount 2
& $VBoxPath storageattach $VmName --storagectl "SATA" --port 0 --device 0 --type hdd --medium $DiskPath
& $VBoxPath storageattach $VmName --storagectl "SATA" --port 1 --device 0 --type dvddrive --medium $IsoPath

& $VBoxPath sharedfolder add $VmName --name "bangla-os" --hostpath $ProjectRoot --automount

Write-Host "Starting unattended Debian 12 installation..."
Write-Host "  Hostname: bangla-os.local"
Write-Host "  User:     banglaos / banglaos"
Write-Host "  SSH:      localhost:2222 (after install + firstboot)"
Write-Host "  ETA:      15-30 minutes"

# Standard desktop selection is more reliable than minimal for unattended installs.
# Post-install packages are applied via scripts/host/wait-and-build.ps1 after SSH is up.
& $VBoxPath unattended install $VmName `
    --iso=$IsoPath `
    --hostname=bangla-os.local `
    --user=banglaos `
    --full-user-name="Bangla OS Builder" `
    --user-password=banglaos `
    --admin-password=banglaos `
    --country=BD `
    --time-zone=Asia/Dhaka `
    --locale=en_US `
    --language=en_US `
    --install-additions `
    --start-vm=gui

Write-Host ""
Write-Host "VM install started. When done, run:"
Write-Host "  .\scripts\host\wait-and-build.ps1"
