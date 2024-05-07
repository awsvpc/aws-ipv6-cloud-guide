#!/bin/bash

# Put your SG ID here!
SG_ID=sg-0000000

wget https://www.cloudflare.com/ips-v4
wget https://www.cloudflare.com/ips-v6

while read -r ipv4
do
  aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 443 \
    --cidr "$ipv4"
done < ips-v4

while read -r ipv6
do
  aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --ip-permissions IpProtocol=tcp,FromPort=443,ToPort=443,Ipv6Ranges='[{CidrIpv6='"$ipv6"'}]'
done < ips-v6
@awsvpc
Comment
