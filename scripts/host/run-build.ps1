#Requires -Version 5.1
<#
.SYNOPSIS
    Run or resume the build pipeline inside the VM via guestcontrol (no WSL).
.PARAMETER From
    Script phase to start from, e.g. 02-xfce. Default: install-all.sh
#>
param(
    [string]$From = "install-all",
    [switch]$ThroughEnd
)

$ErrorActionPreference = "Stop"
$VmName  = "BanglaOS-Build"
$SshPass = "banglaos"

$env:Path = "C:\Program Files\Oracle\VirtualBox;" + $env:Path

if ($From -eq "install-all") {
    $cmd = 'mkdir -p /mnt/bangla-os; mount -t vboxsf bangla-os /mnt/bangla-os; nohup bash /mnt/bangla-os/scripts/build/install-all.sh >> /var/log/bangla-build.log 2>&1 & echo BUILD_STARTED'
} elseif ($ThroughEnd) {
    $phase = $From -replace '\.sh$',''
    $cmd = "mkdir -p /mnt/bangla-os; mount -t vboxsf bangla-os /mnt/bangla-os; nohup bash /mnt/bangla-os/scripts/build/resume-from.sh $phase >> /var/log/bangla-build.log 2>&1 & echo RESUMED_FROM_$phase"
} else {
    $cmd = "mkdir -p /mnt/bangla-os; mount -t vboxsf bangla-os /mnt/bangla-os; nohup bash /mnt/bangla-os/scripts/build/${From}.sh >> /var/log/bangla-build.log 2>&1 & echo RESUMED_FROM_${From}"
}

VBoxManage guestcontrol $VmName run --exe /bin/bash --username root --password $SshPass --wait-stdout -- -c $cmd
