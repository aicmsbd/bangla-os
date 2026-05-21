#Requires -Version 5.1
# Start build VM in QEMU (replaces broken VirtualBox BanglaOS-Build)
$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$Qemu = "C:\Program Files\qemu\qemu-system-x86_64.exe"
$Disk = Join-Path $ProjectRoot "vm\BanglaOS-Build\BanglaOS-Build.qcow2"
$Vdi = Join-Path $ProjectRoot "vm\BanglaOS-Build\BanglaOS-Build.vdi"
$Share = ($ProjectRoot -replace '\\','/')

if (-not (Test-Path $Qemu)) { throw "QEMU not found. Run: winget install SoftwareFreedomConservancy.QEMU" }

if (-not (Test-Path $Disk)) {
    if (-not (Test-Path $Vdi)) { throw "Build disk not found: $Vdi" }
    Write-Host "Converting VDI to QCOW2 (one-time)..."
    $env:Path = "C:\Program Files\qemu;" + $env:Path
    qemu-img convert -p -f vdi -O qcow2 $Vdi $Disk
}

Write-Host "Starting BanglaOS-Build in QEMU..."
Write-Host "  SSH:  ssh -p 2222 banglaos@127.0.0.1  (password: banglaos)"
Write-Host "  ISO rebuild: copy project with scp, then sudo bash scripts/build/09-eggs-build.sh"

$DriveArg = "file=" + ($Disk -replace '\\','/') + ",if=ide,format=qcow2"

& $Qemu `
    -machine pc,accel=tcg `
    -cpu max `
    -m 4096 `
    -smp 2 `
    -drive $DriveArg `
    -boot c `
    -vga std `
    -display gtk `
    -netdev user,id=net0,hostfwd=tcp::2222-:22 `
    -device e1000,netdev=net0
