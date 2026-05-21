#Requires -Version 5.1
<#
.SYNOPSIS
    Waits for BanglaOS-Build VM, runs firstboot + build via VirtualBox guestcontrol.
    Uses Windows localhost (127.0.0.1) for port checks — no WSL.
#>
$ErrorActionPreference = "Continue"

$ProjectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$VmName      = "BanglaOS-Build"
$SshHost     = "127.0.0.1"
$SshPort     = 2222
$SshPass     = "banglaos"
$MaxWaitMin  = 50
$LogFile     = Join-Path $ProjectRoot "vm\build-log.txt"

$env:Path = "C:\Program Files\Oracle\VirtualBox;" + $env:Path

function Test-SshPort {
    $tcp = New-Object System.Net.Sockets.TcpClient
    try {
        $tcp.Connect($SshHost, $SshPort)
        return $true
    } catch { return $false }
    finally { $tcp.Close() }
}

function Invoke-Guest {
    param(
        [string]$User = "root",
        [string]$Command
    )
    & VBoxManage guestcontrol $VmName run --exe /bin/bash --username $User --password $SshPass --wait-stdout -- -c $Command 2>&1
}

Write-Host "[wait-and-build] Waiting for guest execution service (Debian install)..."
$deadline = (Get-Date).AddMinutes($MaxWaitMin)
$guestReady = $false

while ((Get-Date) -lt $deadline) {
    $null = Invoke-Guest -User banglaos -Command "echo ready" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[wait-and-build] Guest execution service ready."
        $guestReady = $true
        break
    }
    Start-Sleep -Seconds 20
    Write-Host "[wait-and-build]   install in progress..."
}

if (-not $guestReady) {
    throw "Guest execution not ready after ${MaxWaitMin} minutes."
}

Write-Host "[wait-and-build] Running firstboot via guestcontrol..."
$firstboot = 'apt-get update; DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server sudo git; usermod -aG sudo banglaos; usermod -aG vboxsf banglaos 2>/dev/null; systemctl enable ssh; systemctl start ssh; mkdir -p /mnt/bangla-os; mount -t vboxsf bangla-os /mnt/bangla-os 2>/dev/null; echo FIRSTBOOT_OK'
Invoke-Guest -Command $firstboot

Write-Host "[wait-and-build] Checking SSH on ${SshHost}:${SshPort} (Windows host)..."
while ((Get-Date) -lt $deadline) {
    if (Test-SshPort) {
        Write-Host "[wait-and-build] SSH port open on Windows localhost."
        break
    }
    Start-Sleep -Seconds 10
}

Write-Host "[wait-and-build] Starting build pipeline via guestcontrol..."
$buildStart = 'mkdir -p /mnt/bangla-os; mount -t vboxsf bangla-os /mnt/bangla-os 2>/dev/null; nohup bash /mnt/bangla-os/scripts/build/install-all.sh > /var/log/bangla-build.log 2>&1 & echo BUILD_STARTED'
Invoke-Guest -Command $buildStart | Tee-Object -FilePath $LogFile

Write-Host ""
Write-Host "[wait-and-build] Build started in VM. Monitor with:"
Write-Host "  .\scripts\host\build-status.ps1"
Write-Host "Log on VM: /var/log/bangla-build.log"
