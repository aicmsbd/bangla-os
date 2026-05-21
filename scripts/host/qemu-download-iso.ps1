#Requires -Version 5.1
# Download latest ISO from QEMU build VM and patch for boot
$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$Py = Join-Path $ProjectRoot "scripts\host\qemu-ssh.py"
$Out = Join-Path $ProjectRoot "output\bangla-os-1.0-amd64.iso"
$Patched = Join-Path $ProjectRoot "output\bangla-os-1.0-amd64-patched.iso"

Write-Host "Finding latest ISO on build VM..."
$remote = python $Py sudo "ls -1t /home/eggs/*.iso 2>/dev/null | head -1" | Select-Object -Last 1
$remote = $remote.Trim()
if (-not $remote) { throw "No ISO on build VM." }
Write-Host "  $remote"

Write-Host "Copying to /tmp for download..."
python $Py sudo "cp '$remote' /tmp/bangla-os.iso && chmod 644 /tmp/bangla-os.iso"

Write-Host "Downloading to $Out ..."
python -c @"
import paramiko, os
c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('127.0.0.1', port=2222, username='banglaos', password='banglaos', timeout=15)
sftp = c.open_sftp()
sftp.get('/tmp/bangla-os.iso', r'$Out')
sftp.close()
c.close()
print('Downloaded', os.path.getsize(r'$Out') // 1024 // 1024, 'MB')
"@

Write-Host "Patching ISO..."
wsl bash "/mnt/c/Users/Z/Desktop/Bangla OS/scripts/host/patch-iso.sh" "/mnt/c/Users/Z/Desktop/Bangla OS/output/bangla-os-1.0-amd64.iso" "/mnt/c/Users/Z/Desktop/Bangla OS/output/bangla-os-1.0-amd64-patched.iso"

Write-Host "Done: $Patched"
