#Requires -Version 5.1
<#
.SYNOPSIS
  Prepare SourceForge upload bundle for Bangla OS ISO mirror.

.DESCRIPTION
  Copies patched ISO, SHA256SUMS, and torrent into output/sourceforge-upload/1.0.1/
  Prints rsync command for SourceForge File Release System (after SSH key setup).
  Opens SourceForge project creation and file upload pages in browser.

.PARAMETER Version
  Release folder name on SourceForge (default: 1.0.1)

.PARAMETER Project
  SourceForge project slug (default: bangla-os)
#>
param(
    [string]$Version = "1.0.1",
    [string]$Project = "bangla-os",
    [switch]$NoPrompt
)
$ErrorActionPreference = "Stop"
$Root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$Out = Join-Path $Root "output"
$Bundle = Join-Path $Out "sourceforge-upload\$Version"
$Iso = Join-Path $Out "bangla-os-1.0-amd64-patched.iso"
$Sums = Join-Path $Root "docs\release\SHA256SUMS"
$Torrent = Join-Path $Out "bangla-os-1.0-amd64-patched.iso.torrent"
$Readme = Join-Path $Bundle "README.txt"

if (-not (Test-Path $Iso)) { throw "Missing ISO: $Iso (run create-all-versions.ps1 first)" }

New-Item -ItemType Directory -Force -Path $Bundle | Out-Null
Copy-Item -Force $Iso $Bundle
Copy-Item -Force $Sums $Bundle
if (Test-Path $Torrent) { Copy-Item -Force $Torrent $Bundle }

$hash = (Get-FileHash $Iso -Algorithm SHA256).Hash.ToLower()
@"
Bangla OS $Version - SourceForge upload bundle
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

Primary file: bangla-os-1.0-amd64-patched.iso
SHA256: $hash

Also upload: SHA256SUMS, bangla-os-1.0-amd64-patched.iso.torrent

After upload, default download URL (adjust project slug if different):
  https://sourceforge.net/projects/$Project/files/$Version/bangla-os-1.0-amd64-patched.iso/download

See docs/release/SOURCEFORGE.md
"@ | Set-Content -Encoding utf8 $Readme

Write-Host ""
Write-Host "=== SourceForge upload bundle ==="
Write-Host "Folder: $Bundle"
Get-ChildItem $Bundle | Format-Table Name, @{N='MB';E={[math]::Round($_.Length/1MB)}} -AutoSize

Write-Host ""
Write-Host "Web upload:"
Write-Host "  1. Create project: https://sourceforge.net/create/"
Write-Host "  2. Files -> Add folder '$Version' -> upload contents of:"
Write-Host "     $Bundle"
Write-Host ""

$SfUser = if ($NoPrompt) { "" } else { Read-Host "SourceForge username (Enter to skip rsync hint)" }
if ($SfUser) {
    $WslBundle = $Bundle -replace '\\','/' -replace '^C:','/mnt/c'
    Write-Host ""
    Write-Host "RSYNC (after SSH key: https://sourceforge.net/auth/shell_services):"
    Write-Host "  wsl rsync -avP --partial '$WslBundle/bangla-os-1.0-amd64-patched.iso' ${SfUser}@frs.sourceforge.net:/home/frs/project/$Project/$Version/"
}

Write-Host ""
if (-not $NoPrompt) {
    Write-Host "Opening SourceForge in browser..."
    Start-Process "https://sourceforge.net/create/"
    Start-Sleep -Seconds 1
    Start-Process "https://sourceforge.net/projects/$Project/files/"
}

Write-Host "Done. Update docs/release/DOWNLOAD.md with mirror URL after upload."
