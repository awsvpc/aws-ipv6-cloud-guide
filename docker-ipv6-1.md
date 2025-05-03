## Docker IPv6

The scenario is where the ISP assigns a /104 IPv6 network 'on link' (i.e. not routed): `xxxx:yyyy:1::9c3:0:0/104`

### Configure Linux host

Add the following to `/etc/sysctl.conf`:
```
# Accept Router Advertisements even if forwarding is enabled.
net.ipv6.conf.eth0.accept_ra = 2

# docker0 must use fe80::1/64, so we need to disable autoconf (SLAAC)
net.ipv6.conf.docker0.autoconf=0
```

### Configure Docker

edit `/etc/sysconfig/docker` and modify `OPTIONS` to look like:
```
OPTIONS=--selinux-enabled --ipv6 --fixed-cidr-v6="xxxx:yyyy:1::9c3:0:0/104"
```

Restart docker `systemctl restart docker`

### Setup NDP proxy

As described in the [Docker doco](https://docs.docker.com/articles/networking/#ipv6-with-docker) you have to work around the fact that the ISP isn't routing the /104 subnet. Obviously, if your ISP *does* route the subnet, then there is no need for this!!

> The container with this address is hidden behind the Docker host. The Docker host has to listen to neighbor solication requests for the container address and send a response that itself is the device that is responsible for the address

For this we either use Linux kernel's *NDP Proxy* feature and add each container IP manually, or we run a daemon such as [ndppd](https://github.com/DanielAdolfsson/ndppd) to take care of this for us. An example `/etc/ndppd.conf` is:

```
route-ttl 30000
proxy eth0 {
   router yes
   timeout 500   
   ttl 30000
   rule xxxx:yyyy:1::9c3:0:0/104 {
      auto
   }
}
```

Simply run `./ndppd`
