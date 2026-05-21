#Requires -Version 5.1
param([switch]$SkipVmCreate)
<#
.SYNOPSIS
    Full ISO rebuild: create build VM, install, build, produce ISO, copy to host.
#>
$ErrorActionPreference = "Continue"

$ProjectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$VmName      = "BanglaOS-Build"
$SshPass     = "banglaos"
$LogFile     = Join-Path $ProjectRoot "vm\rebuild-log.txt"
$IsoOut      = Join-Path $ProjectRoot "output\bangla-os-1.0-amd64.iso"

$env:Path = "C:\Program Files\Oracle\VirtualBox;" + $env:Path

function Log([string]$Msg) {
    $line = "[$(Get-Date -Format 'HH:mm:ss')] $Msg"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line
}

function Invoke-Guest([string]$Cmd, [string]$User = "root") {
    & VBoxManage guestcontrol $VmName run --exe /bin/bash --username $User --password $SshPass --wait-stdout -- -c $Cmd 2>&1
}

Log "=== ISO REBUILD START ==="

# Step 1: Create build VM
if (-not $SkipVmCreate) {
    Log "Creating build VM..."
    & "$ProjectRoot\scripts\host\create-vm.ps1" *>&1 | ForEach-Object { Log $_ }
} else {
    Log "Skipping VM create (already running)."
}

# Step 2: Wait for guest execution
Log "Waiting for Debian install to finish..."
$deadline = (Get-Date).AddMinutes(55)
$guestReady = $false
while ((Get-Date) -lt $deadline) {
    $null = Invoke-Guest "echo ready" "banglaos" 2>&1
    if ($LASTEXITCODE -eq 0) { Log "Guest ready."; $guestReady = $true; break }
    Start-Sleep -Seconds 25
    Log "  install in progress..."
}
if (-not $guestReady) { throw "Guest not ready after 55 min." }

# Step 3: Firstboot
Log "Running firstboot..."
$fb = 'apt-get update; DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server sudo git; usermod -aG sudo banglaos; usermod -aG vboxsf banglaos 2>/dev/null; systemctl enable ssh; systemctl start ssh; mkdir -p /mnt/bangla-os; mount -t vboxsf bangla-os /mnt/bangla-os; echo FIRSTBOOT_OK'
Invoke-Guest $fb | ForEach-Object { Log $_ }

# Step 4: Full build pipeline
Log "Starting build pipeline (30-90 min)..."
Invoke-Guest 'mount -t vboxsf bangla-os /mnt/bangla-os; nohup bash /mnt/bangla-os/scripts/build/install-all.sh > /var/log/bangla-build.log 2>&1 & echo BUILD_STARTED' | ForEach-Object { Log $_ }

# Poll until eggs installed or build log shows resume complete / error
Log "Waiting for build phases 01-08..."
$buildDeadline = (Get-Date).AddMinutes(120)
$eggsReady = $false
while ((Get-Date) -lt $buildDeadline) {
    Start-Sleep -Seconds 60
    $status = Invoke-Guest 'tail -n 8 /var/log/bangla-build.log 2>/dev/null; echo ---; command -v eggs >/dev/null && eggs --version 2>/dev/null || echo NO_EGGS' 2>&1
    if ($status -match 'Bangla OS build environment ready') { Log "Build pipeline done."; $eggsReady = $true; break }
    if ($status -match 'penguins-eggs@\d') { Log "Eggs installed."; $eggsReady = $true; break }
    if ($status -match '^E:') { Log "Build error detected: $status"; break }
    Log "  build in progress..."
}
if (-not $eggsReady) {
    $err = Invoke-Guest 'tail -n 20 /var/log/bangla-build.log' 2>&1
    Log "Build may have failed. Log tail: $err"
}

# Step 5: ISO build
Log "Starting ISO build (20-60 min)..."
Invoke-Guest 'mount -t vboxsf bangla-os /mnt/bangla-os; ln -sf /usr/local/lib/nodejs/bin/eggs /usr/local/bin/eggs 2>/dev/null; nohup bash /mnt/bangla-os/scripts/build/09-eggs-build.sh > /var/log/bangla-iso.log 2>&1 & echo ISO_STARTED' | ForEach-Object { Log $_ }

$isoDeadline = (Get-Date).AddMinutes(90)
$isoPath = ""
while ((Get-Date) -lt $isoDeadline) {
    Start-Sleep -Seconds 90
    $check = Invoke-Guest 'ls /home/eggs/*.iso 2>/dev/null | head -1; tail -n 3 /var/log/bangla-iso.log 2>/dev/null' 2>&1
    Log "  iso build: $($check -join ' | ')"
    if ($check -match '/home/eggs/.*\.iso') {
        $isoPath = ($check | Select-String '/home/eggs/\S+\.iso').Matches[0].Value
        if ($check -match 'ISO build complete') { break }
    }
}

if (-not $isoPath) {
    $fail = Invoke-Guest 'tail -n 30 /var/log/bangla-iso.log' 2>&1
    Log "ISO build failed or timed out: $fail"
    exit 1
}

Log "ISO built at: $isoPath"

# Step 6: Copy to host
Log "Copying ISO to host..."
$guestIso = Invoke-Guest "readlink -f $isoPath 2>/dev/null || ls $isoPath" 2>&1 | Select-Object -Last 1
$guestIso = $guestIso.Trim()
New-Item -ItemType Directory -Force -Path (Split-Path $IsoOut) | Out-Null
& VBoxManage guestcontrol $VmName copyfrom --username root --password $SshPass $guestIso $IsoOut 2>&1 | ForEach-Object { Log $_ }

if (Test-Path $IsoOut) {
    $mb = [math]::Round((Get-Item $IsoOut).Length / 1GB, 2)
    Log "ISO saved: $IsoOut ($mb GB)"
} else {
    Log "ISO copy failed."
    exit 1
}

# Step 7: Patch ISO boot config
Log "Patching ISO boot config..."
wsl -e bash -lc "sudo bash '/mnt/c/Users/Z/Desktop/Bangla OS/scripts/host/patch-iso.sh' '/mnt/c/Users/Z/Desktop/Bangla OS/output/bangla-os-1.0-amd64.iso' '/mnt/c/Users/Z/Desktop/Bangla OS/output/bangla-os-1.0-amd64-patched.iso'" 2>&1 | ForEach-Object { Log $_ }

Log "=== ISO REBUILD COMPLETE ==="

# Step 8: Boot test VM
Log "Starting test VM..."
& "$ProjectRoot\scripts\host\boot-test-vm.ps1" *>&1 | ForEach-Object { Log $_ }
