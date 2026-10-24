#!/usr/bin/env bash
# One-way transfer: wrap sample in a read-only ISO and mount it as the victim's DVD.
set -euo pipefail
[ $# -eq 1 ] && [ -f "$1" ] || { echo "usage: $0 <sample>" >&2; exit 1; }
VM=${VM:-flare-victim}; VBM=${VBM:-VBoxManage}
CTRL=${CTRL:-"SATA Controller"}; PORT=${PORT:-1}

stage=$(mktemp -d); trap 'rm -rf "$stage"' EXIT
cp "$1" "$stage/"
mkdir -p samples
iso="$PWD/samples/$(basename "$1").iso"
sha256sum "$1" 2>/dev/null || shasum -a 256 "$1"   # record hash

genisoimage -quiet -J -r -o "$iso" "$stage" 2>/dev/null \
  || mkisofs -quiet -J -r -o "$iso" "$stage" \
  || hdiutil makehybrid -iso -joliet -o "$iso" "$stage"

"$VBM" storageattach "$VM" --storagectl "$CTRL" --port "$PORT" --device 0 \
  --type dvddrive --medium "$iso" --forceunmount
echo "mounted $iso on $VM"
