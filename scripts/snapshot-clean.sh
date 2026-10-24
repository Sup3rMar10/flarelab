#!/usr/bin/env bash
# Take the "clean" snapshot of the victim (run after `vagrant up`, NAT unplugged).
set -euo pipefail
VM=${VM:-flare-victim}; VBM=${VBM:-VBoxManage}

"$VBM" snapshot "$VM" delete clean 2>/dev/null || true
"$VBM" snapshot "$VM" take clean --live
