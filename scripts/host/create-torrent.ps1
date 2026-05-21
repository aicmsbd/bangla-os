#Requires -Version 5.1
# Create BitTorrent for patched ISO (requires WSL transmission-cli)
$ErrorActionPreference = "Stop"
$Root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$Iso = Join-Path $Root "output\bangla-os-1.0-amd64-patched.iso"
$Torrent = "$Iso.torrent"
if (-not (Test-Path $Iso)) { throw "ISO not found: $Iso" }

$winIso = $Iso -replace '\\','/'
$winTorrent = $Torrent -replace '\\','/'
wsl bash -lc @"
set -e
if ! command -v transmission-create >/dev/null; then
  sudo apt-get update -qq && sudo apt-get install -y -qq transmission-cli
fi
transmission-create -o '/mnt/c/Users/Z/Desktop/Bangla OS/output/bangla-os-1.0-amd64-patched.iso.torrent' \
  -t udp://tracker.opentrackr.org:1337/announce \
  -t udp://open.tracker.cl:1337/announce \
  -c 'Bangla OS 1.0.1 (Padma) amd64 live ISO' \
  '/mnt/c/Users/Z/Desktop/Bangla OS/output/bangla-os-1.0-amd64-patched.iso'
"@

Write-Host "Created: $Torrent"
Get-Item $Torrent | Format-List Name, Length
