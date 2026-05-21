#Requires -Version 5.1
# Wait for QEMU build VM SSH, upload scripts, run ISO rebuild (phase 09)
param([switch]$SkipIsoBuild)
$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$Py = Join-Path $ProjectRoot "scripts\host\qemu-ssh.py"

function Invoke-QemuSsh([string]$Cmd, [switch]$Sudo) {
    $args = @($Py, $(if ($Sudo) { "sudo" } else { "run" }), $Cmd)
    & python @args 2>&1
}

Write-Host "Waiting for QEMU build VM on port 2222..."
$deadline = (Get-Date).AddMinutes(8)
$ready = $false
while ((Get-Date) -lt $deadline) {
    $out = Invoke-QemuSsh "echo ready" 2>$null
    if ($LASTEXITCODE -eq 0) { $ready = $true; break }
    Start-Sleep -Seconds 10
}
if (-not $ready) { throw "Build VM SSH not ready. Start: scripts/host/start-qemu-build.ps1" }

$tar = Join-Path $env:TEMP "bangla-os-scripts.tar"
Push-Location $ProjectRoot
tar -cf $tar scripts config 2>$null
Pop-Location
Invoke-QemuSsh "mkdir -p /tmp/bangla-upload" | Out-Null
& python $Py upload $tar "/tmp/bangla-os-scripts.tar"
Invoke-QemuSsh "mkdir -p /mnt/bangla-os" -Sudo | Out-Null
Invoke-QemuSsh "tar -xf /tmp/bangla-os-scripts.tar -C /mnt/bangla-os" -Sudo | Out-Null

if (-not $SkipIsoBuild) {
    Write-Host "Starting ISO rebuild (20-60 min)..."
    Invoke-QemuSsh "nohup bash /mnt/bangla-os/scripts/build/09-eggs-build.sh > /var/log/bangla-iso-rebuild.log 2>&1 & echo STARTED" -Sudo
    Write-Host "Monitor: python scripts/host/qemu-ssh.py sudo tail -f /var/log/bangla-iso-rebuild.log"
}

Write-Host "Build VM ready."
