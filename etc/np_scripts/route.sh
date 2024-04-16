#!/bin/sh
PATH=/usr/sbin:/sbin:/bin:/usr/bin

iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

#wan=eth0
lan=eth1
dkst=eth2

# Always accept loopback traffic
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections, and those not coming from the outside
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state NEW -i $dkst -j ACCEPT
iptables -A FORWARD -i $lan -o $dkst -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow outgoing connections from the LAN side.
iptables -A FORWARD -i $dkst -o $lan -j ACCEPT

# Masquerade.
iptables -t nat -A POSTROUTING -o $lan -j MASQUERADE

# Don't forward from the outside to the inside.
iptables -A FORWARD -i $dkst -o $lan -j REJECT
iptables -A FORWARD -i $dkst -o $lan -j REJECT
# Enable routing.
echo 1 > /proc/sys/net/ipv4/ip_forward
