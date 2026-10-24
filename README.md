# flarelab — FLARE-VM malware lab (concept/MVP, not for prod)
**Run order** (needs Packer, Vagrant, VirtualBox, VBoxManage on PATH)
1. Put Win10 eval ISO at `packer/iso/win10_eval.iso`; `cd packer && packer init . && packer build .`
2. `vagrant up gw victim` (NAT NIC on victim is unplugged after boot)
3. `scripts/snapshot-clean.sh`  4. `scripts/drop-sample.sh <file>`  5. analyze  6. `scripts/revert.sh`
**Safety checklist**
- [ ] Build needs internet; analysis runs offline (victim NAT link off, host-only only)
- [ ] `VBoxManage controlvm flare-gw setlinkstate1 off` after gw provisioning
- [ ] No shared folders, clipboard, drag-drop, guest additions (verify in VM settings)
- [ ] Host-only net 192.168.56.0/24 only; host firewall blocks forwarding from it
- [ ] Tamper Protection off in base image, else Defender stays on
- [ ] Never put real creds/data in VM; snapshot "clean" before each sample
- [ ] Samples enter via read-only ISO only; nothing leaves the VM
- [ ] Revert after every run; hash samples before handling
