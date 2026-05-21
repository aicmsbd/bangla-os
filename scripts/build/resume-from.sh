#!/bin/bash
# Resume build from a given phase through 08-eggs-install
set -euo pipefail

START="${1:-03-bengali}"
START="${START%.sh}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="${2:-/var/log/bangla-build.log}"

scripts=(03-bengali 04-wine 05-apps 06-theme 07-branding 08-eggs-install)
started=false

exec >> "$LOG" 2>&1
echo ""
echo "=========================================="
echo " Resuming from $START at $(date -R)"
echo "=========================================="

for s in "${scripts[@]}"; do
    if [[ "$started" == false && "$s" != "$START" ]]; then
        continue
    fi
    started=true
    echo ""
    echo "=========================================="
    echo " Running ${s}.sh"
    echo "=========================================="
    bash "$SCRIPT_DIR/${s}.sh"
done

echo ""
echo "=========================================="
echo " Resume complete at $(date -R)"
echo " Reboot, verify desktop, then run 09-eggs-build.sh"
echo "=========================================="
