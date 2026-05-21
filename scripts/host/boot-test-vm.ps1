#Requires -Version 5.1
# Boot test VM with latest patched ISO after rebuild
$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$env:Path = "C:\Program Files\Oracle\VirtualBox;" + $env:Path

$patched = Join-Path $ProjectRoot "output\bangla-os-1.0-amd64-patched.iso"
$iso = if (Test-Path $patched) { $patched } else { Join-Path $ProjectRoot "output\bangla-os-1.0-amd64.iso" }

if (-not (Test-Path $iso)) { throw "No ISO found in output/" }

$ErrorActionPreference = 'SilentlyContinue'
VBoxManage controlvm BanglaOS-Test poweroff 2>&1 | Out-Null
$ErrorActionPreference = 'Stop'
Start-Sleep -Seconds 3

if (-not (VBoxManage list vms | Select-String "BanglaOS-Test")) {
    & "$ProjectRoot\scripts\host\create-test-vm.ps1"
} else {
    VBoxManage storageattach BanglaOS-Test --storagectl SATA --port 1 --device 0 --type dvddrive --medium $iso
    VBoxManage modifyvm BanglaOS-Test --memory 4096 --boot1 dvd --boot2 disk
    VBoxManage startvm BanglaOS-Test --type gui
}

Write-Host "Test VM booting: $iso"
Write-Host "Live login: live / evolution"
