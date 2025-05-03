Networking on my Ubuntu machines is being flaking:

- docker bridge interface failing
- traffic not going to vpns
- when vpn or docker bridge does work it knocks out all dns resolutions

Here are all the things I have tried or yet to try.

# docker failures

- https://github.com/gliderlabs/docker-alpine/issues/255
- https://github.com/gliderlabs/docker-alpine/issues/476
- https://serverfault.com/a/963155
- https://unix.stackexchange.com/q/552025/50703
- https://github.com/docker/for-win/issues/1344


``` bash
# https://serverfault.com/a/963155
noipv4ll  # what is this?

# https://www.daemon-systems.org/man/dhcpcd.8.html
#     When using IPv4LL, dhcpcd nearly always succeeds and returns an exit code
#     of 0.  In the rare case it fails, it normally means that there is a
#     reverse ARP proxy installed which always defeats IPv4LL probing.  To
#     disable this behaviour, you can use the -L, --noipv4ll option.
#    -L, --noipv4ll
#             Don't use IPv4LL (aka APIPA, aka Bonjour, aka ZeroConf).
# ^ not helpful at explaining at all

# https://unix.stackexchange.com/a/658014/50703
# Udhcpc need /etc/udhcpc/udhcpc.conf, accessible by all, with a single line dns="ns1 ns2"
# ^ also a terrible explanation
```

# transmission

``` bash
# https://help.ubuntu.com/community/TransmissionHowTo
sudo vim /var/lib/transmission-daemon/info/settings.json
sudo usermod -a -G debian-transmission user
# "umask": 2, - WHY WHAT IS THIS

# https://wiki.debian.org/Transmission
apt install transmission-daemon  --install-suggests
systemctl edit transmission-daemon.service
```

# docker vpn

- https://hub.docker.com/r/linuxserver/transmission
- https://github.com/haugene/docker-transmission-openvpn
- https://hub.docker.com/r/gzm55/vpn-client/

# nordvpn config

- https://nordvpn.com/ovpn/
- https://support.nordvpn.com/Connectivity/Linux/1322207652/Troubleshooting-connectivity-Linux.htm
- https://wiki.archlinux.org/title/NordVPN
- https://support.nordvpn.com/Connectivity/Linux/1325531132/Installing-and-using-NordVPN-on-Debian-Ubuntu-Raspberry-Pi-Elementary-OS-and-Linux-Mint.htm

``` bash
# https://www.makeuseof.com/how-to-install-nordvpn-ubuntu/
nordvpn set autoconnect on
```

# ufw

``` bash
# https://askubuntu.com/a/1230322/22776
sudo ufw allow 1194/udp
```

# disable ipv6

apparently many things doesn't support it, including nord, however there is conflicting information about this

``` bash
# https://wiki.archlinux.org/title/IPv6#Disable_IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.nic0.disable_ipv6 = 1
net.ipv6.conf.nicN.disable_ipv6 = 1

noipv6rs
noipv6

nmcli connection modify ConnectionName ipv6.method "disabled"

```

# ip route

``` bash
# https://serverfault.com/a/472364
ip route show table main
ip route add 88.191.250.176 via <gatewayip> dev eth3

```

# wireguard

``` bash
# https://bbs.archlinux.org/viewtopic.php?id=251317
Install wireguard-tools.

# https://www.cyberciti.biz/faq/ubuntu-20-04-set-up-wireguard-vpn-server/
sudo apt install wireguard
sudo ufw allow 41194/udp
sudo systemctl enable wg-quick@wg0
# and a bunch of other stuff
```

``` bash
# https://askubuntu.com/a/1378515/22776
# no idea
sudo edit /etc/ppp/ip-up.d/0000usepeerdns
```

# nexthop

``` bash
# https://bbs.archlinux.org/viewtopic.php?id=243382
ip a
ip r
systemctl list-unit-files --state=enabled
```

# protonvpn

``` bash
# https://protonvpn.com/support/linux-vpn-setup/
# doesn't seem there is arm support for the official protonvpn client

# https://protonvpn.com/support/linux-openvpn/
#  Note: to use our NetShield DNS filtering feature, append the suffix +f1 to your username to block malware, or +f2  to block malware, ads, and trackers (for example 123456789+f2).
sudo apt-get install openvpn
sudo wget "https://raw.githubusercontent.com/ProtonVPN/scripts/master/update-resolv-conf.sh" -O "/etc/openvpn/update-resolv-conf"
```

# openvpn scripts

``` bash
# https://openvpn.net/vpn-server-resources/connecting-to-access-server-with-linux/
openvpn3 session-start --config ${client.ovpn}
openvpn3 sessions-list
openvpn --config client.ovpn --auth-user-pass --auth-retry interact
script-security 2
up /etc/openvpn/update-resolv-conf
down /etc/openvpn/update-resolv-conf
```

``` bash
# https://www.ivpn.net/setup/linux-terminal/
ip a | grep tun
curl https://api.ivpn.net/v4/geo-lookup
curl https://api.ivpn.net/v4/geo-lookup | jq
grep -i vpn /var/log/syslog
```

# nordvpn scripts

``` bash
# nord support
sudo iptables -P INPUT ACCEPT
sudo iptables -F INPUT 
sudo iptables -P OUTPUT ACCEPT
sudo iptables -F OUTPUT
sudo systemctl restart NetworkManager
```

``` bash
# https://support.nord-help.com/Connectivity/Linux/1325531132/Installing-and-using-NordVPN-on-Debian-Ubuntu-Raspberry-Pi-Elementary-OS-and-Linux-Mint.htm
nordvpn whitelist add port 22 - Add a rule to whitelist a specified incoming port. You can also whitelist multiple ports — just separate their numbers with a space.
nordvpn whitelist remove port 22 - Remove the rule to whitelist a specified port.
nordvpn whitelist add subnet 192.168.0.0/16 - Add a rule to whitelist a specified subnet.
nordvpn whitelist remove subnet 192.168.0.0/16  - Remove the rule to whitelist a specified subnet.
```

- https://github.com/search?p=2&q=nordvpn+iptables&type=Code
- https://github.com/search?q=nordvpn+forward&type=Code

``` bash
# https://www.reddit.com/r/nordvpn/comments/jodvfs/comment/gb7f5yj/?utm_source=reddit&utm_medium=web2x&context=3
# required nordlynx to actually initiate
ip table rule. sudo iptables -t nat -A POSTROUTING -o nordlynx -j MASQUERADE
sudo iptables -A FORWARD -i wlan0 -o nordlynx -j ACCEPT
sudo iptables -A FORWARD -i nordLynx -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
```

# openvpn

``` bash
# https://openvpn.net/community-resources/how-to/
a whole bunch of routing and iptable stuff that doesn't seem relevant
```

``` bash
# https://community.openvpn.net/openvpn/wiki/IgnoreRedirectGateway
--pull-filter ignore redirect-gateway
--route-noexec 
--route-nopull 
def1 -- Use this flag to override the default gateway by using 0.0.0.0/1 and 128.0.0.0/1 rather than 0.0.0.0/0. This has the benefit of overriding but not wiping out the original default gateway.
route 0.0.0.0 128.0.0.0 net_gateway
route 128.0.0.0 128.0.0.0 net_gateway
route 0.0.0.0 192.0.0.0 net_gateway
route 64.0.0.0 192.0.0.0 net_gateway
route 128.0.0.0 192.0.0.0 net_gateway
route 192.0.0.0 192.0.0.0 net_gateway
```

# general debugging

```
route
ip addr
ip route
ip rule
ifconfig
tcpdump -i eth0
traceroute 8.8.8.8
sudo iptables -L -v
```

# RTNETLINK errors

``` bash
# JUST REBOOT

# https://stackoverflow.com/a/27708858/130638
# https://stackoverflow.com/a/64473630/130638
# --cap-add=NET_ADMIN
# http://linux.die.net/man/7/capabilities

# https://raspberrypi.stackexchange.com/a/51947/134746
sudo ip addr flush dev wlan0

# https://raspberrypi.stackexchange.com/a/65753/134746
sudo ifup --ignore-errors wlan0

# https://raspberrypi.stackexchange.com/a/79881/134746
ifdown --force --verbose ethX && ifup --force --verbose ethX

# https://askubuntu.com/a/313367/22776
sudo ifdown eth0 && sudo ifup -v eth0

# https://debugah.com/ubuntu-how-to-solve-rtnetlink-answers-file-exists-two-methods-5679/
ip addr flush dev eth0  # nukes network access until ifup is run
ip addre flush dev eth1
ifdown eth0 && ifup eth0 && ifdown eth1 && ifup eth1

# https://stackoverflow.com/a/53961002/130638
sudo tc qdisc replace dev eth0 root netem delay 100ms
sudo tc qdisc del dev eth0 root
sudo tc qdisc add dev eth0 root netem delay 100ms
```

# syncthing

``` xml
# https://docs.syncthing.net/users/config.html
# https://docs.syncthing.net/users/config.html#gui-element
<gui enabled="true" tls="false" debugging="false">
    <address>0.0.0.0:8384</address>
</gui>

# https://docs.syncthing.net/users/guilisten.html
```


# docker transmission

``` bash
# https://haugene.github.io/docker-transmission-openvpn/config-options/#dropping_default_route_from_iptables_advanced
# https://github.com/haugene/docker-transmission-openvpn/
# https://github.com/haugene/docker-transmission-openvpn/search?q=DROP_DEFAULT_ROUTE

Network configuration options¶
Variable	Function	Example
OPENVPN_CONFIG	Sets the OpenVPN endpoint to connect to.	OPENVPN_CONFIG=UK Southampton
OPENVPN_OPTS	Will be passed to OpenVPN on startup	See OpenVPN doc
LOCAL_NETWORK	Sets the local network that should have access. Accepts comma separated list.	LOCAL_NETWORK=192.168.0.0/24
CREATE_TUN_DEVICE	Creates /dev/net/tun device inside the container, mitigates the need mount the device from the host	CREATE_TUN_DEVICE=true
PEER_DNS	Controls whether to use the DNS provided by the OpenVPN endpoint.	To use your host DNS rather than what is provided by OpenVPN, set PEER_DNS=false. This allows for potential DNS leakage.
PEER_DNS_PIN_ROUTES	Controls whether to force traffic to peer DNS through the OpenVPN tunnel.	To disable this default, set PEER_DNS_PIN_ROUTES=false.


Some VPNs do not override the default route, but rather set other routes with a lower metric. This might lead to the default route (your untunneled connection) to be used.

To drop the default route set the environment variable DROP_DEFAULT_ROUTE to true.

Note: This is not compatible with all VPNs. You can check your iptables routing with the ip r command in a running container.

# https://github.com/haugene/docker-transmission-openvpn/blob/d1ece1c5f36f275d5d950bd2557ec43f79a80d14/transmission/start.sh#L70-L74
/sbin/ip route del default via "${route_net_gateway}" 
```

# ufw

``` bash
# https://askubuntu.com/a/98252/22776
sudo ufw enable
sudo ufw allow 22/tcp
```

``` bash
# https://linuxconfig.org/how-to-enable-disable-firewall-on-ubuntu-20-04-lts-focal-fossa-linux
sudo ufw status
sudo ufw status verbose
sudo ufw disable
sudo ufw enable
```

# docker

- https://docs.docker.com/engine/reference/commandline/dockerd/
- https://docs.docker.com/config/daemon/systemd/
- https://docs.docker.com/engine/reference/commandline/dockerd/#feature-options
- https://docs.docker.com/network/bridge/#use-the-default-bridge-network

``` bash
# https://stackoverflow.com/a/68992601/130638
docker network prune
```

```
# https://docs.docker.com/network/bridge/#use-the-default-bridge-network
# Configure the default bridge network
{
  "bip": "192.168.1.1/24",
  "fixed-cidr": "192.168.1.0/25",
  "fixed-cidr-v6": "2001:db8::/64",
  "mtu": 1500,
  "default-gateway": "192.168.1.254",
  "default-gateway-v6": "2001:db8:abcd::89",
  "dns": ["10.20.1.2","10.20.1.3"]
}
```

```
# daemon.json
{
  "allow-nondistributable-artifacts": [],
  "authorization-plugins": [],
  "bridge": "",
  "cluster-advertise": "",
  "cluster-store": "",
  "containerd": "\\\\.\\pipe\\containerd-containerd",
  "containerd-namespace": "docker",
  "containerd-plugin-namespace": "docker-plugins",
  "data-root": "",
  "debug": true,
  "default-ulimits": {},
  "dns": [],
  "dns-opts": [],
  "dns-search": [],
  "exec-opts": [],
  "experimental": false,
  "features": {},
  "fixed-cidr": "",
  "group": "",
  "hosts": [],
  "insecure-registries": [],
  "labels": [],
  "log-driver": "",
  "log-level": "",
  "max-concurrent-downloads": 3,
  "max-concurrent-uploads": 5,
  "max-download-attempts": 5,
  "mtu": 0,
  "pidfile": "",
  "raw-logs": false,
  "registry-mirrors": [],
  "shutdown-timeout": 15,
  "storage-driver": "",
  "storage-opts": [],
  "swarm-default-advertise-addr": "",
  "tlscacert": "",
  "tlscert": "",
  "tlskey": "",
  "tlsverify": true
}
debug: it changes the daemon to debug mode when set to true.
cluster-store: it reloads the discovery store with the new address.
cluster-store-opts: it uses the new options to reload the discovery store.
cluster-advertise: it modifies the address advertised after reloading.
labels: it replaces the daemon labels with a new set of labels.
live-restore: Enables keeping containers alive during daemon downtime.
max-concurrent-downloads: it updates the max concurrent downloads for each pull.
max-concurrent-uploads: it updates the max concurrent uploads for each push.
max-download-attempts: it updates the max download attempts for each pull.
default-runtime: it updates the runtime to be used if not is specified at container creation. It defaults to “default” which is the runtime shipped with the official docker packages.
runtimes: it updates the list of available OCI runtimes that can be used to run containers.
authorization-plugin: it specifies the authorization plugins to use.
allow-nondistributable-artifacts: Replaces the set of registries to which the daemon will push nondistributable artifacts with a new set of registries.
insecure-registries: it replaces the daemon insecure registries with a new set of insecure registries. If some existing insecure registries in daemon’s configuration are not in newly reloaded insecure registries, these existing ones will be removed from daemon’s config.
registry-mirrors: it replaces the daemon registry mirrors with a new set of registry mirrors. If some existing registry mirrors in daemon’s configuration are not in newly reloaded registry mirrors, these existing ones will be removed from daemon’s config.
shutdown-timeout: it replaces the daemon’s existing configuration timeout with a new timeout for shutting down all containers.
features: it explicitly enables or disables specific features.

# flags
The -b, --bridge= flag is set to docker0 as default bridge network. It is created automatically when you install Docker. If you are not using the default, you must create and configure the bridge manually or just set it to ‘none’: --bridge=none
--exec-root is the path where the container state is stored. The default value is /var/run/docker. Specify the path for your running daemon here.
--data-root is the path where persisted data such as images, volumes, and cluster state are stored. The default value is /var/lib/docker. To avoid any conflict with other daemons, set this parameter separately for each daemon.
-p, --pidfile=/var/run/docker.pid is the path where the process ID of the daemon is stored. Specify the path for your pid file here.
--host=[] specifies where the Docker daemon will listen for client connections. If unspecified, it defaults to /var/run/docker.sock.
--iptables=false prevents the Docker daemon from adding iptables rules. If multiple daemons manage iptables rules, they may overwrite rules set by another daemon. Be aware that disabling this option requires you to manually add iptables rules to expose container ports. If you prevent Docker from adding iptables rules, Docker will also not add IP masquerading rules, even if you set --ip-masq to true. Without IP masquerading rules, Docker containers will not be able to connect to external hosts or the internet when using network other than default bridge.
--config-file=/etc/docker/daemon.json is the path where configuration file is stored. You can use it instead of daemon flags. Specify the path for each daemon.
--tls* Docker daemon supports --tlsverify mode that enforces encrypted and authenticated remote connections. The --tls* options enable use of specific certificates for individual daemons.
sudo dockerd \
        -H unix:///var/run/docker-bootstrap.sock \
        -p /var/run/docker-bootstrap.pid \
        --iptables=false \
        --ip-masq=false \
        --bridge=none \
        --data-root=/var/lib/docker-bootstrap \
        --exec-root=/var/run/docker-bootstrap
```


``` bash
# https://stackoverflow.com/a/35519951/130638
# /etc/systemd/system/docker.service.d/docker.conf 
# [Service]
# ExecStart=
# ExecStart=/usr/bin/docker daemon -H fd:// --bip=192.168.169.1/24

systemctl stop docker

# We need a program called brctl to, well, control the bridge, which is part of the bridge-utils package.
sudo apt-get install bridge-utils

#Bring down the docker0 interface:
sudo ip link set docker0 down

# And delete the bridge.
sudo brctl delbr docker0

# Finally, start the Docker daemon
systemctl start docker
```

``` bash
https://www.suse.com/support/kb/doc/?id=000018916
DOCKER_OPTS="--bip=192.168.1.1/24"
```

``` bash
# https://github.com/kubernetes-sigs/kubespray/issues/213#issuecomment-212974520
ExecStartPre=-/usr/bin/ip link set dev docker0 down
ExecStartPre=-/usr/sbin/brctl delbr docker0
```

``` bash
# https://github.com/moby/moby/issues/42558#issuecomment-905313588
# don't work, breaks more things
sudo apt remove netscript-2.4
```

``` bash
# https://stackoverflow.com/a/64793583/130638
sysctl -w net.ipv4.ip_forward=1
```

``` bash
# https://docs.docker.com.zh.xy2401.com/v17.09/engine/userguide/networking/default_network/custom-docker0/
sudo apt-get install bridge-utils
sudo brctl show
{
  "bip": "192.168.1.5/24",
  "fixed-cidr": "192.168.1.5/25",
  "fixed-cidr-v6": "2001:db8::/64",
  "mtu": 1500,
  "default-gateway": "10.20.1.1",
  "default-gateway-v6": "2001:db8:abcd::89",
  "dns": ["10.20.1.2","10.20.1.3"]
}
The same options are presented as flags to dockerd, with an explanation for each:

--bip=CIDR: supply a specific IP address and netmask for the docker0 bridge, using standard CIDR notation. For example: 192.168.1.5/24.

--fixed-cidr=CIDR and --fixed-cidr-v6=CIDRv6: restrict the IP range from the docker0 subnet, using standard CIDR notation. For example: 172.16.1.0/28. This range must be an IPv4 range for fixed IPs, and must be a subset of the bridge IP range (docker0 or set using --bridge or the bip key in the daemon.json file). For example, with --fixed-cidr=192.168.1.0/25, IPs for your containers will be chosen from the first half of addresses included in the 192.168.1.0/24 subnet.

--mtu=BYTES: override the maximum packet length on docker0.

--default-gateway=Container default Gateway IPV4 address and --default-gateway-v6=Container default gateway IPV6 address: designates the default gateway for containers connected to the docker0 bridge, which controls where they route traffic by default. Applicable for addresses set with --bip and --fixed-cidr flags. For instance, you can configure --fixed-cidr=172.17.2.0/24 and default-gateway=172.17.1.1.

--dns=[]: The DNS servers to use. For example: --dns=172.17.2.10.
```

``` bash
# https://docs.docker.com.zh.xy2401.com/v17.09/engine/userguide/networking/default_network/container-communication/#communication-between-containers
sysctl net.ipv4.conf.all.forwarding=1
iptables -I DOCKER -i ext_if ! -s 8.8.8.8 -j DROP
sudo iptables -L -n
sudo iptables -P FORWARD ACCEPT
```

``` bash
# https://stackoverflow.com/a/43932266/130638
{
"bip": "192.168.1.5/24",
"fixed-cidr": "192.168.1.0/25"
}
```

```
# https://support.microfocus.com/kb/doc.php?id=7023491
{
  "bip": "192.168.1.5/24",
  "fixed-cidr": "192.168.1.5/25",
  "fixed-cidr-v6": "2001:db8::/64",
  "mtu": 1500,
  "default-gateway": "10.20.1.1",
  "default-gateway-v6": "2001:db8:abcd::89",
  "dns": ["10.20.1.2","10.20.1.3"]
}
```

``` bash
# https://developpaper.com/question/the-docker-container-cannot-connect-to-the-internet/
sysctl net.ipv4.ip_forward
iptables -t nat -L POSTROUTING
iptables -t nat -L POSTROUTING | grep masquerade
```

``` bash
# https://github.com/moby/moby/issues/36151#issuecomment-811024910
lsmod | grep br_netfilter
modprobe br_netfilter
netstat -i
ip link set dev docker0 promisc on
```

``` bash
# https://earthly.dev/blog/docker-networking/
docker network ls     
docker ps
docker network inspect bridge    
```

``` bash
# https://maximorlov.com/4-reasons-why-your-docker-containers-cant-talk-to-each-other/
docker network create -o com.docker.network.bridge.enable_icc=true [network]
```

``` bash
# https://www.reddit.com/r/docker/comments/o3axmn/docker_has_no_internet_access/
# https://stackoverflow.com/a/70421216/130638
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 04EE7237B7D453EC 648ACFD622F3D138
    echo "deb http://deb.debian.org/debian buster-backports main" | sudo tee -a /etc/apt/sources.list.d/buster-backports.list
    sudo apt update
    sudo apt install -t buster-backports libseccomp2
```

``` bash
# https://github.com/moby/moby/issues/36151#issuecomment-370978922
# https://stackoverflow.com/a/20431030/130638
# https://superuser.com/a/1130993/32418
sudo systemctl stop docker
sudo pkill docker
sudo iptables -t nat -F
sudo ifconfig docker0 down
sudo brctl delbr docker0
sudo systemctl start docker
```

``` bash
# https://github.com/docker/for-win/issues/221#issuecomment-597431251
sudo route -n add -net 172.x.0.0/16  $(docker-machine ip default)
sudo iptables -L
sudo iptables -I DOCKER-USER  -j ACCEPT
```

``` bash
# https://stackoverflow.com/a/39801518/130638
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
iptables -t nat -I OUTPUT -p tcp -d 127.0.0.1 --dport 80 -j REDIRECT --to-ports 8080
```

``` bash
# https://stackoverflow.com/a/49621509/130638
sudo service iptables stop
sudo service docker restart
```

``` bash
# https://stackoverflow.com/a/70939554/130638
sudo ip link delete docker0
```

``` bash
# https://stackoverflow.com/a/68092908/130638
docker run --security-opt seccomp=unconfined imageName
```

``` bash
# https://github.com/moby/moby/issues/36151#issuecomment-968356070
# https://stackoverflow.com/a/70452290/130638
sudo systemctl disable nftables
sudo systemctl stop nftables
sudo reboot
sudo systemctl start docker
```

    

# dns

```
# https://support.nordvpn.com/Connectivity/Linux/1134945702/Change-your-DNS-servers-on-Linux.htm
# https://support.nordvpn.com/General-info/1047409702/What-are-your-DNS-server-addresses.htm
nameserver 103.86.96.100
nameserver 103.86.99.100
chattr +i /etc/resolv.conf
```

# resolvectl default route

```
# https://www.freedesktop.org/software/systemd/man/resolvectl.html
dns [LINK [SERVER…]], domain [LINK [DOMAIN…]], default-route [LINK [BOOL…]], llmnr [LINK [MODE]], mdns [LINK [MODE]], dnssec [LINK [MODE]], dnsovertls [LINK [MODE]], nta [LINK [DOMAIN…]]
Get/set per-interface DNS configuration. These commands may be used to configure various DNS settings for network interfaces. These commands may be used to inform systemd-resolved or systemd-networkd about per-interface DNS configuration determined through external means. The dns command expects IPv4 or IPv6 address specifications of DNS servers to use. Each address can optionally take a port number separated with ":", a network interface name or index separated with "%", and a Server Name Indication (SNI) separated with "#". When IPv6 address is specified with a port number, then the address must be in the square brackets. That is, the acceptable full formats are "111.222.333.444:9953%ifname#example.com" for IPv4 and "[1111:2222::3333]:9953%ifname#example.com" for IPv6. The domain command expects valid DNS domains, possibly prefixed with "~", and configures a per-interface search or route-only domain. The default-route command expects a boolean parameter, and configures whether the link may be used as default route for DNS lookups, i.e. if it is suitable for lookups on domains no other link explicitly is configured for. The llmnr, mdns, dnssec and dnsovertls commands may be used to configure the per-interface LLMNR, MulticastDNS, DNSSEC and DNSOverTLS settings. Finally, nta command may be used to configure additional per-interface DNSSEC NTA domains.

Commands dns, domain and nta can take a single empty string argument to clear their respective value lists.

For details about these settings, their possible values and their effect, see the corresponding settings in systemd.network(5).
```

> The default-route command expects a boolean parameter, and configures whether the link may be used as default route for DNS lookups, i.e. if it is suitable for lookups on domains no other link explicitly is configured for.

``` bash
# https://systemd.io/RESOLVED-VPNS/
resolvectl domain corporate0 '~corp-company.example' '~2.0.192.in-addr.arpa'
resolvectl default-route corporate0 false
resolvectl dns corporate0 192.0.2.1
resolvectl domain privacy0 '~.'
resolvectl default-route privacy0 true
resolvectl dns privacy0 8.8.8.8
```

# openvpn

``` bash
# https://askubuntu.com/a/466011/22776
# https://serverfault.com/a/953745
# https://serverfault.com/a/480098
redirect-gateway def1
```

- apparently this needs server-side config
- why isn't this config already inside the `.ovpn` files from nord?

# openvpn and iptables

```
# https://community.openvpn.net/openvpn/wiki/BridgingAndRouting

dev tun
topology subnet
server 10.8.0.0 255.255.255.0
push "route 192.168.0.0 255.255.255.0"

push "redirect-gateway def1"

# Allow traffic initiated from VPN to access LAN
iptables -I FORWARD -i tun0 -o eth0 \
     -s 10.8.0.0/24 -d 192.168.0.0/24 \
     -m conntrack --ctstate NEW -j ACCEPT

# Allow established traffic to pass back and forth
iptables -I FORWARD -m conntrack --ctstate RELATED,ESTABLISHED \
     -j ACCEPT

# Masquerade all traffic from VPN clients -- done in the nat table 
iptables -t nat -I POSTROUTING -o eth0 \
      -s 10.8.0.0/24 -j MASQUERADE
```

``` bash
# https://askubuntu.com/a/578550/22776
iptables -I FORWARD -i tun0 -o eth0 \
         -s 10.8.0.0/24 -m conntrack --ctstate NEW -j ACCEPT

iptables -I FORWARD -m conntrack --ctstate RELATED,ESTABLISHED \
         -j ACCEPT

iptables -t nat -I POSTROUTING -o eth0 \
          -s 10.8.0.0/24 -j MASQUERADE
          
# https://askubuntu.com/a/1341821/22776
push "redirect-gateway autolocal"

# https://askubuntu.com/a/1157242/22776
push "redirect-gateway def1 bypass-dhcp"
redirect-gateway def1 bypass-dhcp

# https://forums.openvpn.net/viewtopic.php?t=27618
pull-filter ignore "redirect-gateway def1 bypass-dhcp" pull-filter ignore "dhcp-option DNS 192.168.55.1" pull-filter ignore "dhcp-option DOMAIN example.com" route 192.168.55.0 255.255.255.0

# https://blog.sellorm.com/2017/03/01/force-all-traffic-through-openvpn-connection/
redirect-gateway def1

# https://erwinbierens.com/route-all-traffic-by-openvpn/
push "redirect-gateway def1"
push "dhcp-option DNS "
push "dhcp-option DNS 1.1.1.1"
sudo /etc/init.d/openvpn restart
redirect-gateway def1
iptables -I FORWARD -i tun0 -o wlan0 \
        -s 10.8.0.0/24 -m conntrack --ctstate NEW -j ACCEPT
iptables -I FORWARD -m conntrack --ctstate RELATED,ESTABLISHED \
        -j ACCEPT
iptables -t nat -I POSTROUTING -o wlan0 \
        -s 10.8.0.0/24 -j MASQUERADE
```

# iptables debugging

``` bash
# list rules
iptables --line-numbers -t filter -L FORWARD
```

# iptables forwarding

``` bash
# https://upcloud.com/resources/tutorials/configure-iptables-ubuntu
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Next, allow traffic to a specific port to enable SSH connections with the following.
sudo iptables -A INPUT -p tcp --dport ssh -j ACCEPT

# To enable access to an HTTP web server, use the following command.
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# hanging the default rule to drop will permit only specifically accepted connection.
sudo iptables -P INPUT DROP

# Now if you were to restart your cloud server all of these iptables configurations would be wiped. To prevent this, save the rules to a file.
sudo iptables-save > /etc/iptables/rules.v4

# You can then simply restore the saved rules by reading the file you saved.
# Overwrite the current rules
sudo iptables-restore < /etc/iptables/rules.v4
# Add the new rules keeping the current ones
sudo iptables-restore -n < /etc/iptables/rules.v4

# You can automate the restore process at reboot by installing an additional package for iptables which takes over the loading of the saved rules. To this with the following command.
sudo apt-get install iptables-persistent
# If you make further changes to your iptables rules, remember to save them again using the same command as above. The iptables-persistent looks for the files rules.v4 and rules.v6 under /etc/iptables.

# To know which index number to enter, use the following command.
sudo iptables -L --line-numbers

# For example to insert a new rule to the top of the chain, use the following command with index number 1.
sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT

# For example to delete the second rule on the input chain, use this command.
# sudo iptables -D INPUT 2

# Warning: Make sure you set the default rule to ACCEPT before flushing any chain.
sudo iptables -P INPUT ACCEPT

# Clear input chain
sudo iptables -F INPUT
# Flush the whole iptables
sudo iptables -F
```

``` bash
# https://www.hostinger.com/tutorials/iptables-tutorial

# sudo iptables -A <chain> -i <interface> -p <protocol (tcp/udp) > -s <source> --dport <port no.>  -j <target>
# -i (interface) — the network interface whose traffic you want to filter, such as eth0, lo, ppp0, etc.
# -p (protocol) — the network protocol where your filtering process takes place. It can be either tcp, udp, udplite, icmp, sctp, icmpv6, and so on. Alternatively, you can type all to choose every protocol.
# -s (source) — the address from which traffic comes from. You can add a hostname or IP address.
# –dport (destination port) — the destination port number of a protocol, such as 22 (SSH), 443 (https), etc.
# -j (target) — the target name (ACCEPT, DROP, RETURN). You need to insert this every time you make a new rule.

# list rules
sudo iptables -L -v

# To allow traffic on localhost, type this command:
sudo iptables -A INPUT -i lo -j ACCEPT

# Enabling Connections on HTTP, SSH, and SSL Port
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Filtering Packets Based on Source
sudo iptables -A INPUT -s 192.168.1.3 -j ACCEPT
sudo iptables -A INPUT -s 192.168.1.3 -j DROP
sudo iptables -A INPUT -m iprange --src-range 192.168.1.100-192.168.1.200 -j DROP

# Dropping all Other Traffic
sudo iptables -A INPUT -j DROP

# Deleting Rules
sudo iptables -F # erase all apparently aka flush
sudo iptables -L --line-numbers # list rules
sudo iptables -D INPUT 3  # delete a specific rule

# Persisting Changes across reboots
sudo /sbin/iptables-save

# Disable iptables
sudo iptables -F
sudo /sbin/iptables-save
```

``` bash
# https://askubuntu.com/a/218053/22776
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE  -j DROP
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,PSH,ACK,URG -j DROP
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,PSH,URG -j DROP
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,ACK,URG -j DROP
-A INPUT -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j DROP
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
-A INPUT -m state --state INVALID -j DROP
```

``` bash
# https://serverfault.com/a/1025183
update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
update-alternatives --set arptables /usr/sbin/arptables-legacy
update-alternatives --set ebtables /usr/sbin/ebtables-legacy
```

``` bash
# https://serverfault.com/a/480098
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
```

``` bash
# https://askubuntu.com/a/578550/22776
iptables -I FORWARD -i tun0 -o eth0 \
         -s 10.8.0.0/24 -m conntrack --ctstate NEW -j ACCEPT

iptables -I FORWARD -m conntrack --ctstate RELATED,ESTABLISHED \
         -j ACCEPT

iptables -t nat -I POSTROUTING -o eth0 \
          -s 10.8.0.0/24 -j MASQUERADE
```

``` bash
# https://serverfault.com/a/200658
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X

ip6tables -P INPUT ACCEPT
ip6tables -P FORWARD ACCEPT
ip6tables -P OUTPUT ACCEPT
ip6tables -t nat -F
ip6tables -t mangle -F
ip6tables -F
ip6tables -X

iptables -nvL
```

``` bash
# https://serverfault.com/a/200642
iptables-save | awk '/^[*]/ { print $1 } 
                     /^:[A-Z]+ [^-]/ { print $1 " ACCEPT" ; }
                     /COMMIT/ { print $0; }' | iptables-restore
```

``` bash
# https://serverfault.com/a/962809
iptables-save | tee iptables_backup.conf | grep -v '\-A' | iptables-restore
iptables-restore < iptables_backup.conf
```

``` bash
# https://serverfault.com/a/998574
# It resets (and disables) ufw and then resets iptables clearing and removing all chains. Then it enables the ufw again, but not before it allows port 22 for remote access. The two commands that require user confirmation are "forced" ensuring no input is required. I was able to run this over an active SSH connection.
sudo bash -c "ufw -f reset && iptables -F && iptables -X && ufw allow 22 && ufw -f enable"
```

``` bash
# https://serverfault.com/a/1002428
iptables -S |grep DROP| sed 's/-A/-D/' >rules  # -A becomes -D: delete
nano rules  # check that everything is correct
cat rules | while read line; do iptables $line; done
iptables-save
```

``` bash
# https://serverfault.com/a/1082227
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -t filter -F
sudo iptables -t raw -F

sudo iptables -t nat -X
sudo iptables -t mangle -X
sudo iptables -t filter -X
sudo iptables -t raw -X

echo "=== NAT ==="; sudo iptables -t nat -S; echo "\n=== MANGLE ==="; sudo iptables -t mangle -S; echo "\n=== FILTER ==="; sudo iptables -t filter -S; echo "\n=== RAW ==="; sudo iptables -t raw -S
```

``` bash
# https://unix.stackexchange.com/a/283803/50703
# Masquerade outgoing traffic
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE

# Allow return traffic
iptables -A INPUT -i eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Forward everything
iptables -A FORWARD -j ACCEPT
```

``` bash
# https://unix.stackexchange.com/a/283802/50703
-I FORWARD 1 -m state --state RELATED,ESTABLISHED -j ACCEPT
```

``` bash
# https://serverfault.com/a/866668
# too complicated no explanation
```

``` bash
# https://arashmilani.com/post?id=53
iptables -A INPUT -i eth0 -m state --state NEW -p udp --dport 1194 -j ACCEPT
iptables -A INPUT -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables -A OUTPUT -o tun+ -j ACCEPT
```

- why is linux help never explanatory, what do those commands even do?
