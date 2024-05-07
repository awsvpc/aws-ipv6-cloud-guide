#!/bin/sh

## Credits to @gdamjan this script is partially based on his 6rd script (https://gist.github.com/gdamjan/1141850)
## You must have a real routable IPv4 address for IPv6 rapid deployment (6rd)
## tunnels.
## Also make sure you have at least linux kernel 2.6.33 and you have enabled 6rd
## CONFIG_IPV6_SIT_6RD=y

PREFIX="2001:b07"        # Fastweb 6rd ipv6 prefix
GATEWAY="81.208.50.214"  # Fastweb 6rd gateway host
DGW_NIC="$(ip -4 r sh default | awk '{print $5}')" # Get NIC name by looking at default gw on Linux routing table

modprobe sit

## Try to autodetect the local ipv4 address
MYIPV4=`dig +short myip.opendns.com @resolver1.opendns.com`

## Generate an IPv6-RD address
MYIPV4_nodots=`echo ${MYIPV4} | tr . ' '`
IPV6=`printf "${PREFIX}:%02x%02x:%02x%02x::1" ${MYIPV4_nodots}`

## Setup the tunnel (replace eth0 with the right NIC)
ip tunnel add 6rd mode sit remote ${GATEWAY}
ip addr add ${IPV6}/64 dev ${DGW_NIC}
ip link set 6rd up
ip -6 route add default dev 6rd


## IPv6-rd allows you to have IPv6 network in your LAN too. Uncomment the
## following 3 lines on your Linux router and set the correct LAN interface.
## You might also want to run the 'radvd' sevice to enable IPv6 auto-configuration
## on the LAN.

# sysctl -w net.ipv6.conf.all.forwarding=1
# LANIF=eth0
# ip addr add ${IPV6}/64 dev ${LANIF}
