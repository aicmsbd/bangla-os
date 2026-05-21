#Requires -Version 5.1
# Create GitHub release for Bangla OS 1.0 (ISO may exceed 2GB GitHub limit)
param([string]$Tag = "v1.0.0", [string]$Iso = "")
$ErrorActionPreference = "Stop"
$Root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$Notes = Join-Path $Root "docs\release\RELEASE-NOTES-1.0.md"
$Checksums = Join-Path $Root "docs\release\SHA256SUMS"
$Patched = if ($Iso) { $Iso } else { Join-Path $Root "output\bangla-os-1.0-amd64-patched.iso" }

if (-not (Test-Path $Notes)) { throw "Missing $Notes" }

$body = Get-Content $Notes -Raw
gh release create $Tag --title "Bangla OS 1.0 (Padma)" --notes $body
gh release upload $Tag $Checksums

if (Test-Path $Patched) {
    $mb = [math]::Round((Get-Item $Patched).Length / 1MB)
    if ($mb -gt 1900) {
        Write-Warning "ISO is ${mb} MB — GitHub limit is 2048 MB. Skipping ISO upload."
        Write-Host "Host ISO locally or use SourceForge; checksums are on the release."
    } else {
        gh release upload $Tag $Patched
    }
}

Write-Host "Release: $(gh release view $Tag --json url -q .url)"
