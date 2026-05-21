#Requires -Version 5.1
# Rebuild ISO v1.0.1 with Phase 2 branding — start VM, brand, produce, package
param([switch]$SkipVmStart)
$ErrorActionPreference = "Stop"
$Root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$HostScripts = Join-Path $Root "scripts\host"

if (-not $SkipVmStart) {
    $ssh = netstat -an | Select-String "2222.*LISTENING"
    if (-not $ssh) {
        Write-Host "[v1.0.1] Starting build VM..."
        Start-Process powershell -ArgumentList @(
            '-NoProfile', '-ExecutionPolicy', 'Bypass',
            '-File', (Join-Path $HostScripts "start-qemu-build.ps1")
        ) -WindowStyle Minimized
        Start-Sleep -Seconds 15
    }
}

& (Join-Path $HostScripts "qemu-run-iso-build.ps1")
Write-Host "[v1.0.1] Rebuild started. When complete, run:"
Write-Host "  python scripts/host/qemu-ssh.py sudo tail -8 /var/log/bangla-iso-rebuild.log"
Write-Host "  .\scripts\host\create-all-versions.ps1 -SkipRebuild"
