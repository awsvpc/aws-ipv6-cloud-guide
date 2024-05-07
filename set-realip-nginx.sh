#!/bin/bash

# Получить последние IP-адреса Cloudflare
IPS_IPV4_CLOUDFLARE=$(curl https://www.cloudflare.com/ips-v4)
IPS_IPV6_CLOUDFLARE=$(curl https://www.cloudflare.com/ips-v6)

# Получить последние IP-адреса Google Cloud
IPS_IPV4_GOOGLECLOUD=$(curl https://www.gstatic.com/ipranges/cloud.json | jq -r '.prefixes[] | select(.ipv4Prefix) | .ipv4Prefix')
IPS_IPV6_GOOGLECLOUD=$(curl https://www.gstatic.com/ipranges/cloud.json | jq -r '.prefixes[] | select(.ipv6Prefix) | .ipv6Prefix')

# Получить последние IP-адреса AWS
IPS_IPV4_AWS=$(curl https://ip-ranges.amazonaws.com/ip-ranges.json | jq -r '.prefixes[] | select(.service=="AMAZON") | .ip_prefix')
IPS_IPV6_AWS=$(curl https://ip-ranges.amazonaws.com/ip-ranges.json | jq -r '.ipv6_prefixes[] | select(.service=="AMAZON") | .ipv6_prefix')

echo "# Cloudflare IPv4" > /etc/nginx/conf.d/x_real_ip.conf;
for ip in $IPS_IPV4_CLOUDFLARE; do
    echo "set_real_ip_from $ip;" >> /etc/nginx/conf.d/x_real_ip.conf;
done
echo "
# Cloudflare IPv6" >> /etc/nginx/conf.d/x_real_ip.conf;
for ip in $IPS_IPV6_CLOUDFLARE; do
    echo "set_real_ip_from $ip;" >> /etc/nginx/conf.d/x_real_ip.conf;
done

echo "
# Google Cloud IPv4" >> /etc/nginx/conf.d/x_real_ip.conf;
for ip in $IPS_IPV4_GOOGLECLOUD; do
    echo "set_real_ip_from $ip;" >> /etc/nginx/conf.d/x_real_ip.conf;
done
echo "
# Google Cloud IPv6" >> /etc/nginx/conf.d/x_real_ip.conf;
for ip in $IPS_IPV6_GOOGLECLOUD; do
    echo "set_real_ip_from $ip;" >> /etc/nginx/conf.d/x_real_ip.conf;
done

echo "
# AWS IPv4" >> /etc/nginx/conf.d/x_real_ip.conf;
for ip in $IPS_IPV4_AWS; do
    echo "set_real_ip_from $ip;" >> /etc/nginx/conf.d/x_real_ip.conf;
done
echo "
# AWS IPv6" >> /etc/nginx/conf.d/x_real_ip.conf;
for ip in $IPS_IPV6_AWS; do
    echo "set_real_ip_from $ip;" >> /etc/nginx/conf.d/x_real_ip.conf;
done

# Перезагрузить Nginx
service nginx configtest && service nginx reload
