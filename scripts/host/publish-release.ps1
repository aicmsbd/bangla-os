#Requires -Version 5.1
<#
.SYNOPSIS
  Sync release artifacts after ISO build: checksums, torrent, SourceForge bundle, GitHub upload.

.PARAMETER Tag
  GitHub release tag (default: v1.0.1)

.PARAMETER SkipGithub
  Skip gh release upload

.PARAMETER SkipSourceforge
  Skip SourceForge bundle preparation
#>
param(
    [string]$Tag = "v1.0.1",
    [switch]$SkipGithub,
    [switch]$SkipSourceforge
)
$ErrorActionPreference = "Stop"
$Root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$Out = Join-Path $Root "output"
$Docs = Join-Path $Root "docs\release"
$Iso = Join-Path $Out "bangla-os-1.0-amd64-patched.iso"

if (-not (Test-Path $Iso)) {
    throw "Missing patched ISO. Run: .\scripts\host\create-all-versions.ps1 -SkipRebuild"
}

Write-Host "[publish] Verifying ISO offline..."
& python (Join-Path $Root "scripts\host\qemu-live-test.py")
if ($LASTEXITCODE -ne 0) { throw "Offline verify failed" }

Write-Host "[publish] SHA256SUMS..."
$files = @("bangla-os-1.0-amd64.iso", "bangla-os-1.0-amd64-patched.iso", "bangla-os-1.0-amd64-serial.iso")
$lines = foreach ($f in $files) {
    $p = Join-Path $Out $f
    if (Test-Path $p) {
        $h = (Get-FileHash $p -Algorithm SHA256).Hash.ToLower()
        "$h  $f"
    }
}
$lines | Set-Content -Encoding ascii (Join-Path $Out "SHA256SUMS")
$lines | Set-Content -Encoding ascii (Join-Path $Docs "SHA256SUMS")

Write-Host "[publish] Torrent..."
& (Join-Path $Root "scripts\host\create-torrent.ps1")

if (-not $SkipSourceforge) {
    Write-Host "[publish] SourceForge bundle..."
    & (Join-Path $Root "scripts\host\prepare-sourceforge-upload.ps1") -NoPrompt
}

if (-not $SkipGithub) {
    Write-Host "[publish] GitHub release $Tag..."
    $sums = Join-Path $Docs "SHA256SUMS"
    $torrent = Join-Path $Out "bangla-os-1.0-amd64-patched.iso.torrent"
    $download = Join-Path $Docs "DOWNLOAD.md"
    gh release upload $Tag $sums $torrent $download --clobber
}

Write-Host ""
Write-Host "=== Published locally ==="
$lines
Write-Host ""
Write-Host "Next: upload output/sourceforge-upload/1.0.1/ to SourceForge"
Write-Host "      post docs/release/REDDIT-POST.md and BENGALI-POST.md"
