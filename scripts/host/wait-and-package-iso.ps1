#Requires -Version 5.1
# Wait for build VM ISO rebuild, then download and package all versions
param([int]$TimeoutMinutes = 120)
$ErrorActionPreference = "Stop"
$Root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$Py = Join-Path $Root "scripts\host\qemu-ssh.py"
$Log = Join-Path $Root "output\rebuild-v1.0.1.log"

function Ssh([string]$Cmd) {
    & python $Py sudo $Cmd 2>&1 | Out-String
}

$deadline = (Get-Date).AddMinutes($TimeoutMinutes)
Write-Host "[wait-package] Waiting for ISO build complete..."
while ((Get-Date) -lt $deadline) {
    $tail = Ssh "tail -3 /var/log/bangla-iso-rebuild.log 2>/dev/null"
    if ($tail -match "ISO build complete") {
        Write-Host "[wait-package] Build finished."
        break
    }
    $time = Get-Date -Format "HH:mm:ss"
    Add-Content $Log "`n[$time] still building..."
    Write-Host "[$time] building..."
    Start-Sleep -Seconds 90
}
if ($tail -notmatch "ISO build complete") {
    Write-Error "Timed out after $TimeoutMinutes minutes"
}

& (Join-Path $Root "scripts\host\create-all-versions.ps1") -SkipRebuild
& (Join-Path $Root "scripts\host\create-torrent.ps1")
Write-Host "[wait-package] All versions ready in output/"
