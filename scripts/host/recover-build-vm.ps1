#Requires -Version 5.1
# Re-register BanglaOS-Build after VirtualBox "Aborted" session errors (keeps disk)
$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$VBoxFile = Join-Path $ProjectRoot "vm\BanglaOS-Build\BanglaOS-Build\BanglaOS-Build.vbox"
$env:Path = "C:\Program Files\Oracle\VirtualBox;" + $env:Path

if (-not (Test-Path $VBoxFile)) { throw "VM definition not found: $VBoxFile" }

$existing = VBoxManage list vms | Select-String "BanglaOS-Build"
if ($existing) {
    Write-Host "Unregistering broken VM registration (keeping disks)..."
    VBoxManage unregistervm BanglaOS-Build
}

Write-Host "Registering BanglaOS-Build from existing disk..."
VBoxManage registervm $VBoxFile

Write-Host "Starting VM (GUI — use this if headless fails)..."
VBoxManage startvm BanglaOS-Build --type gui

Write-Host "If the VM window opens, the build environment is intact."
Write-Host "Then run: scripts/host/run-build.ps1 -Phase 09"
