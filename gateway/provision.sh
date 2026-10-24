#!/usr/bin/env bash
# Fake-internet gateway: INetSim answers DNS and all common services.
set -euo pipefail
GW=192.168.56.10
IF=enp0s8   # host-only NIC

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq inetsim iptables-persistent

# Free port 53 for INetSim DNS
systemctl disable --now systemd-resolved || true
rm -f /etc/resolv.conf && echo "nameserver 127.0.0.1" > /etc/resolv.conf

cat >> /etc/inetsim/inetsim.conf <<EOF
service_bind_address $GW
dns_default_ip       $GW
dns_default_domainname lab.local
EOF
systemctl enable --now inetsim

# Hardcoded-IP traffic arriving from victim is redirected to local fake services
for p in 21 25 80 110 143 443 990 995; do
  iptables -t nat -A PREROUTING -i $IF ! -d $GW -p tcp --dport $p -j REDIRECT
done
iptables -t nat -A PREROUTING -i $IF ! -d $GW -p udp --dport 53 -j REDIRECT
# Never route anywhere
sysctl -w net.ipv4.ip_forward=0
iptables -P FORWARD DROP
netfilter-persistent save
