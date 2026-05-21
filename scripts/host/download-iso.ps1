#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$IsoDir      = Join-Path $ProjectRoot "iso"
$IsoName     = "debian-12.11.0-amd64-netinst.iso"
$IsoUrl      = "https://cdimage.debian.org/cdimage/archive/12.11.0/amd64/iso-cd/$IsoName"
$IsoPath     = Join-Path $IsoDir $IsoName

New-Item -ItemType Directory -Force -Path $IsoDir | Out-Null

if (Test-Path $IsoPath) {
    $mb = [math]::Round((Get-Item $IsoPath).Length / 1MB, 1)
    Write-Host "ISO already present: $IsoPath ($mb MB)"
    exit 0
}

Write-Host "Downloading Debian 12.11.0 netinst (~670 MB)..."
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $IsoUrl -OutFile $IsoPath -UseBasicParsing
Write-Host "Saved: $IsoPath"
