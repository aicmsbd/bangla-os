#Requires -Version 5.1
# Boot Bangla OS ISO in QEMU (alternative to VirtualBox for live testing)
$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$Qemu = "C:\Program Files\qemu\qemu-system-x86_64.exe"
$Iso = Join-Path $ProjectRoot "output\bangla-os-1.0-amd64-patched.iso"
if (-not (Test-Path $Iso)) { $Iso = Join-Path $ProjectRoot "output\bangla-os-1.0-amd64.iso" }

if (-not (Test-Path $Qemu)) { throw "QEMU not found. Install: winget install SoftwareFreedomConservancy.QEMU" }
if (-not (Test-Path $Iso)) { throw "ISO not found in output/" }

$RamMb = if ($env:BANGLA_TEST_RAM_MB) { [int]$env:BANGLA_TEST_RAM_MB } else { 8192 }
$Cpu = if ($env:BANGLA_TEST_CPU) { [int]$env:BANGLA_TEST_CPU } else { 4 }
$Display = if ($env:BANGLA_QEMU_HEADLESS -eq "1") { @("-display", "none", "-serial", "stdio") } else { @("-display", "gtk") }

Write-Host "Booting in QEMU: $Iso"
Write-Host "Live login: live / evolution"
Write-Host "Close QEMU window to stop."

& $Qemu `
    -machine pc,accel=tcg `
    -cpu max `
    -m $RamMb `
    -smp $Cpu `
    -cdrom $Iso `
    -boot d `
    -vga std `
    -netdev user,id=net0 `
    -device e1000,netdev=net0 `
    @Display
