#Requires -Version 5.1
# Boot Bangla OS ISO in QEMU at 1 GB RAM (weak-PC profile from todo Phase 1.11)
$ErrorActionPreference = "Stop"
$env:BANGLA_TEST_RAM_MB = "1024"
$env:BANGLA_TEST_CPU = "2"
& (Join-Path $PSScriptRoot "boot-qemu-test.ps1")
