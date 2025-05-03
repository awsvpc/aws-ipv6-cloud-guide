#!/bin/bash
# Put this script into your crontab e.g. 
# @reboot ~/bin/bounce_ipv6.sh
# Bounce IPv6 connection if router is up but IPv6 connectivity is down,
# and check the connection every 30 seconds.
router_address="192.168.0.1"
ipvsixaddress="2600::"
while true;
do
  if ping -c1 $router_address &>/dev/null; then
    if ping -c1 $ipvsixaddress &>/dev/null; then
      :
    else
      echo "Resetting ipv6 connection..."
      primary_connection=$(nmcli -t -f UUID con | head -n 1)
      sudo nmcli connection modify "$primary_connection" ipv6.method "disabled"
      sudo nmcli connection up "$primary_connection"
      sudo nmcli connection modify "$primary_connection" ipv6.method "auto"
      sudo nmcli connection up "$primary_connection"
    fi
  fi
  sleep 30
done

-=======================


firewalld network manager

#!/bin/bash
connection="System eth0"
ip4="192.168.168"
ip6="fd00:168:168"
1_interfaces () {
hostnamectl set-hostname router
nmcli c mod "$connection" ipv4.addresses $ip4.1/24
nmcli c mod "$connection" ipv4.method manual
nmcli c mod "$connection" ipv6.addresses $ip6::1/64
nmcli c mod "$connection" ipv6.method manual
nmcli c mod "$connection" connection.zone internal
nmcli c up  "$connection"
}
2_routing () {
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -p
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf
}
3_firewall () {
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --zone=internal --add-service=dns --permanent
firewall-cmd --zone=internal --add-service=dhcp --permanent
firewall-cmd --zone=internal --add-service=dhcpv6 --permanent
firewall-cmd --zone=internal --add-source=${ip4}.0/24 --permanent
firewall-cmd --zone=internal --add-source=${ip6}::/64 --permanent
firewall-cmd --zone=public --add-masquerade --permanent
firewall-cmd --reload
}
4_dhcp-dns () {
yum -y install dnsmasq*
echo "dhcp-range=$ip4.50,$ip4.150,255.255.255.0,12h" > /etc/dnsmasq.d/eth0.conf
echo "dhcp-option=3,$ip4.1" >> /etc/dnsmasq.d/eth0.conf
echo "dhcp-range=$ip6::2,$ip6::500,slaac" >> /etc/dnsmasq.d/eth0.conf
systemctl enable dnsmasq
systemctl start dnsmasq
}

1_interfaces
2_routing
3_firewall
4_dhcp-dns

=============================

cloudflare-dns.sh

(
  IFS=$'\n'
  for line in $(nmcli --fields UUID,TYPE,NAME connection show); do
    conn_uuid=$(echo ${line} | cut -d ' ' -f 1)
    conn_type=$(echo ${line} | cut -d ' ' -f 3)
    conn_name=$(echo ${line} | cut -d ' ' -f 4- | xargs)
    if [ "${conn_type}" = "wifi" ]; then
      echo "name: $(tput bold)${conn_name}"
      echo "$(tput dim)uuid: ${conn_uuid}, type: ${conn_type}"
      nmcli connection modify ${conn_uuid} ipv4.dns "1.1.1.1,1.0.0.1"
      nmcli connection modify ${conn_uuid} ipv4.ignore-auto-dns yes
      nmcli connection modify ${conn_uuid} ipv6.dns "2606:4700:4700::1111,2606:4700:4700::1001"
      nmcli connection modify ${conn_uuid} ipv6.ignore-auto-dns yes
      nmcli connection show ${conn_uuid} | grep dns --color=never
      echo "$(tput sgr0)"
    fi
  done
)

=============

while read i; do
  echo "Setting up connection $i ..."
  sudo nmcli conn modify "$i" ipv6.addr-gen-mode eui64
  sudo nmcli conn modify id "$i" 802-11-wireless.cloned-mac-address permanent # This is only relevant when using Wifi
  sudo nmcli conn modify "$i" ipv4.dns "1.1.1.1"
  sudo nmcli conn modify "$i" ipv6.dns "2606:4700:4700::1111"
  sudo nmcli conn up "$i"
done <<< "$(nmcli -g name conn show)"

==================

network-manager-dns.sh

nmcli -g name,type connection  show  --active | awk -F: '/ethernet|wireless/ { print $1 }' | while read connection
do
  nmcli con mod "$connection" ipv6.ignore-auto-dns yes
  nmcli con mod "$connection" ipv4.ignore-auto-dns yes
  nmcli con mod "$connection" ipv4.dns "8.8.8.8 8.8.4.4"
  nmcli con down "$connection" && nmcli con up "$connection"
done

===================

disable ipv6 on wifi

#!/bin/bash

for con in natbusa "natbusa 5G";
do 
  echo ipv6.method ignore connection: \"$con\"
  nmcli con modify "$con" ipv6.method ignore
done;

===========

