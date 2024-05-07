aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 80 --cidr 173.245.48.0/20 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 80 --cidr 103.21.244.0/22 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 80 --cidr 103.22.200.0/22 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 80 --cidr 103.31.4.0/22 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 80 --cidr 141.101.64.0/18 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 80 --cidr 108.162.192.0/18 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 80 --cidr 190.93.240.0/20 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 80 --cidr 188.114.96.0/20 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 80 --cidr 197.234.240.0/22 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 80 --cidr 198.41.128.0/17 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 80 --cidr 162.158.0.0/15 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 80 --cidr 104.16.0.0/13 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 80 --cidr 104.24.0.0/14 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 80 --cidr 172.64.0.0/13 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 80 --cidr 131.0.72.0/22 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --ip-permissions IpProtocol=tcp,FromPort=80,ToPort=80,Ipv6Ranges="[{CidrIpv6=2400:cb00::/32}]" --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --ip-permissions IpProtocol=tcp,FromPort=80,ToPort=80,Ipv6Ranges="[{CidrIpv6=2606:4700::/32}]" --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --ip-permissions IpProtocol=tcp,FromPort=80,ToPort=80,Ipv6Ranges="[{CidrIpv6=2803:f800::/32}]" --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --ip-permissions IpProtocol=tcp,FromPort=80,ToPort=80,Ipv6Ranges="[{CidrIpv6=2405:b500::/32}]" --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --ip-permissions IpProtocol=tcp,FromPort=80,ToPort=80,Ipv6Ranges="[{CidrIpv6=2405:8100::/32}]" --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --ip-permissions IpProtocol=tcp,FromPort=80,ToPort=80,Ipv6Ranges="[{CidrIpv6=2a06:98c0::/29}]" --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --ip-permissions IpProtocol=tcp,FromPort=80,ToPort=80,Ipv6Ranges="[{CidrIpv6=2c0f:f248::/32}]" --profile profile_name --region region_name

aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 443 --cidr 173.245.48.0/20 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 443 --cidr 103.21.244.0/22 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 443 --cidr 103.22.200.0/22 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 443 --cidr 103.31.4.0/22 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 443 --cidr 141.101.64.0/18 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 443 --cidr 108.162.192.0/18 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 443 --cidr 190.93.240.0/20 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 443 --cidr 188.114.96.0/20 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 443 --cidr 197.234.240.0/22 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 443 --cidr 198.41.128.0/17 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 443 --cidr 162.158.0.0/15 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 443 --cidr 104.16.0.0/13 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 443 --cidr 104.24.0.0/14 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 443 --cidr 172.64.0.0/13 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --protocol tcp --port 443 --cidr 131.0.72.0/22 --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --ip-permissions IpProtocol=tcp,FromPort=443,ToPort=443,Ipv6Ranges="[{CidrIpv6=2400:cb00::/32}]" --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --ip-permissions IpProtocol=tcp,FromPort=443,ToPort=443,Ipv6Ranges="[{CidrIpv6=2606:4700::/32}]" --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --ip-permissions IpProtocol=tcp,FromPort=443,ToPort=443,Ipv6Ranges="[{CidrIpv6=2803:f800::/32}]" --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --ip-permissions IpProtocol=tcp,FromPort=443,ToPort=443,Ipv6Ranges="[{CidrIpv6=2405:b500::/32}]" --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --ip-permissions IpProtocol=tcp,FromPort=443,ToPort=443,Ipv6Ranges="[{CidrIpv6=2405:8100::/32}]" --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --ip-permissions IpProtocol=tcp,FromPort=443,ToPort=443,Ipv6Ranges="[{CidrIpv6=2a06:98c0::/29}]" --profile profile_name --region region_name
aws ec2 authorize-security-group-ingress --group-id sg-xxxxxxxxxxxxxxxxxxxx --ip-permissions IpProtocol=tcp,FromPort=443,ToPort=443,Ipv6Ranges="[{CidrIpv6=2c0f:f248::/32}]" --profile profile_name --region region_name
