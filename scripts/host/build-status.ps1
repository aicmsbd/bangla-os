#Requires -Version 5.1
<#
.SYNOPSIS
    Show Bangla OS build progress from the VM (no WSL).
#>
$ErrorActionPreference = "Continue"

$VmName  = "BanglaOS-Build"
$SshPass = "banglaos"
$SshHost = "127.0.0.1"
$SshPort = 2222

$env:Path = "C:\Program Files\Oracle\VirtualBox;" + $env:Path

Write-Host "=== VM state ==="
VBoxManage showvminfo $VmName --machinereadable | Select-String "VMState"

Write-Host "`n=== SSH (Windows localhost) ==="
$tcp = New-Object System.Net.Sockets.TcpClient
try {
    $tcp.Connect($SshHost, $SshPort)
    Write-Host "Port ${SshHost}:${SshPort} open"
} catch {
    Write-Host "Port ${SshHost}:${SshPort} closed"
} finally { $tcp.Close() }

Write-Host "`n=== Build log (last 20 lines) ==="
VBoxManage guestcontrol $VmName run --exe /bin/tail --username root --password $SshPass --wait-stdout -- -n 20 /var/log/bangla-build.log 2>&1
