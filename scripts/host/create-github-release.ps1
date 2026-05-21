#Requires -Version 5.1
# Create GitHub release (ISO may exceed 2GB GitHub limit — uploads checksums + torrent)
param(
    [string]$Tag = "v1.0.1",
    [string]$Title = "",
    [string]$NotesFile = "",
    [string]$Iso = ""
)
$ErrorActionPreference = "Stop"
$Root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$ver = $Tag -replace '^v', ''
$Notes = if ($NotesFile) { $NotesFile } else { Join-Path $Root "docs\release\RELEASE-NOTES-$ver.md" }
if (-not (Test-Path $Notes)) {
    $Notes = Join-Path $Root "docs\release\RELEASE-NOTES-1.0.md"
}
$Checksums = Join-Path $Root "docs\release\SHA256SUMS"
$Torrent = Join-Path $Root "output\bangla-os-1.0-amd64-patched.iso.torrent"
$Download = Join-Path $Root "docs\release\DOWNLOAD.md"
$Patched = if ($Iso) { $Iso } else { Join-Path $Root "output\bangla-os-1.0-amd64-patched.iso" }
$Title = if ($Title) { $Title } else { "Bangla OS $ver (Padma)" }

if (-not (Test-Path $Notes)) { throw "Missing $Notes" }

$body = Get-Content $Notes -Raw
gh release create $Tag --title $Title --notes $body
gh release upload $Tag $Checksums $Download

if (Test-Path $Torrent) {
    gh release upload $Tag $Torrent
    Write-Host "Uploaded torrent."
}

if (Test-Path $Patched) {
    $mb = [math]::Round((Get-Item $Patched).Length / 1MB)
    if ($mb -gt 1900) {
        Write-Warning "ISO is ${mb} MB - GitHub limit is 2048 MB. Skipping ISO upload."
        Write-Host "Use torrent or build from source; see docs/release/DOWNLOAD.md"
    } else {
        gh release upload $Tag $Patched
    }
}

$url = gh release view $Tag --json url -q ".url"
Write-Host "Release: $url"
