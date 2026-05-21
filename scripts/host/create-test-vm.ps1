#Requires -Version 5.1
<#
.SYNOPSIS
    Deletes BanglaOS-Build and creates BanglaOS-Test VM booting the Bangla OS ISO.
#>
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$VBoxPath    = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$BuildVm     = "BanglaOS-Build"
$TestVm      = "BanglaOS-Test"
$IsoPath     = Join-Path $ProjectRoot "output\bangla-os-1.0-amd64-patched.iso"
if (-not (Test-Path $IsoPath)) {
    $IsoPath = Join-Path $ProjectRoot "output\bangla-os-1.0-amd64.iso"
}
$VmDir       = Join-Path $ProjectRoot "vm\BanglaOS-Test"
$DiskPath    = Join-Path $VmDir "BanglaOS-Test.vdi"

if (-not (Test-Path $VBoxPath)) { throw "VirtualBox not found." }
if (-not (Test-Path $IsoPath)) { throw "ISO not found: $IsoPath" }

$env:Path = "C:\Program Files\Oracle\VirtualBox;" + $env:Path

# Remove build VM
$existing = & $VBoxPath list vms 2>$null | Select-String "`"$BuildVm`""
if ($existing) {
    Write-Host "Removing build VM '$BuildVm'..."
    $ErrorActionPreference = 'SilentlyContinue'
    & $VBoxPath controlvm $BuildVm poweroff 2>&1 | Out-Null
    $ErrorActionPreference = 'Stop'
    Start-Sleep -Seconds 5
    & $VBoxPath unregistervm $BuildVm --delete
}

# Remove old test VM if present
$existingTest = & $VBoxPath list vms 2>$null | Select-String "`"$TestVm`""
if ($existingTest) {
    Write-Host "Removing existing '$TestVm'..."
    $ErrorActionPreference = 'SilentlyContinue'
    & $VBoxPath controlvm $TestVm poweroff 2>&1 | Out-Null
    $ErrorActionPreference = 'Stop'
    Start-Sleep -Seconds 3
    & $VBoxPath unregistervm $TestVm --delete
}

New-Item -ItemType Directory -Force -Path $VmDir | Out-Null

Write-Host "Creating test VM '$TestVm'..."
& $VBoxPath createvm --name $TestVm --ostype "Debian_64" --register --basefolder $VmDir

& $VBoxPath modifyvm $TestVm `
    --memory 4096 `
    --vram 128 `
    --cpus 2 `
    --ioapic on `
    --boot1 dvd --boot2 disk --boot3 none --boot4 none `
    --nic1 nat `
    --audio-driver none `
    --graphicscontroller vboxsvga `
    --firmware bios `
    --rtcuseutc on

& $VBoxPath createmedium disk --filename $DiskPath --size 20480 --format VDI
& $VBoxPath storagectl $TestVm --name "SATA" --add sata --controller IntelAhci --portcount 2
& $VBoxPath storageattach $TestVm --storagectl "SATA" --port 0 --device 0 --type hdd --medium $DiskPath
& $VBoxPath storageattach $TestVm --storagectl "SATA" --port 1 --device 0 --type dvddrive --medium $IsoPath

Write-Host "Starting '$TestVm' from Bangla OS ISO..."
Write-Host "  Live login: live / evolution"
& $VBoxPath startvm $TestVm --type gui

Write-Host ""
Write-Host "Test VM booting. Select 'Live' or wait for auto-boot."
