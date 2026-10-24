#!/usr/bin/env bash
# Roll the victim back to "clean" and restart headless.
set -euo pipefail
VM=${VM:-flare-victim}; VBM=${VBM:-VBoxManage}

"$VBM" controlvm "$VM" poweroff 2>/dev/null || true
sleep 3
"$VBM" snapshot "$VM" restore clean
"$VBM" startvm "$VM" --type headless
