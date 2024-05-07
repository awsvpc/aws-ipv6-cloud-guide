resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true
  assign_generated_ipv6_cidr_block = true
  tags = "${
     merge(var.tags, map("Name", format("%s", var.name )))
  }"
}

resource "aws_vpc_dhcp_options" "poc" {
  domain_name          = "poc.ews.works"
  domain_name_servers  = ["AmazonProvidedDNS"]
#  ntp_servers          = ["1.rhel.pool.ntp.org", "2.us.pool.ntp.org"]
}

resource "aws_vpc_dhcp_options_association" "poc-dhcp-dns" {
  vpc_id          = "${aws_vpc.vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.poc.id}"
}

resource "aws_route53_zone" "poc_sub" {
  name = "poc.ews.works"
}
resource "aws_route53_zone" "poc_private" {
  name   = "poc.ews.works"
  vpc_id = "${aws_vpc.vpc.id}"
}
resource "aws_route53_record" "poc_sub" {
  zone_id = "${data.aws_route53_zone.ews_domain.zone_id}"
  name    = "poc.ews.works"
  type    = "NS"
  ttl     = 3600

  records = [
    "${aws_route53_zone.poc_sub.name_servers.0}",
    "${aws_route53_zone.poc_sub.name_servers.1}",
    "${aws_route53_zone.poc_sub.name_servers.2}",
    "${aws_route53_zone.poc_sub.name_servers.3}",
  ]
}

resource "aws_acm_certificate" "poc_cert" {
  domain_name       = "poc.ews.works"
  validation_method = "DNS"
}

resource "aws_route53_record" "access_high_level_domain" {
  zone_id = "${data.aws_route53_zone.ews_domain.zone_id}"
  name    = "access.ews.works"
  type    = "A"
  ttl     = 3600
  records = [ "${aws_eip.jump_host_ip.public_ip}" ]
}

resource "aws_network_interface" "jump-public-iface" {
  subnet_id   = "${aws_subnet.presentation_subnets.1.id}"
  private_ips = ["10.200.21.11"]
  security_groups = [
    "${aws_security_group.jumphost.id}",
    "${aws_security_group.personal_access.id}"
  ]
}
resource "aws_network_interface" "jump-internal-iface" {
  subnet_id   = "${aws_subnet.admin_subnets.1.id}"
  private_ips = ["10.200.11.11"]
  security_groups = [
    "${aws_security_group.jumphost.id}",
    "${aws_security_group.personal_access.id}"
  ]
}

resource "aws_eip" "jump_host_ip" {
  vpc   = true
  associate_with_private_ip = "10.200.21.11"
  tags = {
    purpose = "jumphost_bastion"
  }
}

resource "aws_route53_record" "aws_poc_cert" {
  name    = "${aws_acm_certificate.poc_cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.poc_cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${aws_route53_zone.poc_sub.id}"
  records = ["${aws_acm_certificate.poc_cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 900
}

resource "aws_acm_certificate_validation" "aws_poc_cert" {
  certificate_arn         = "${aws_acm_certificate.poc_cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.aws_poc_cert.fqdn}"]
}


resource "aws_internet_gateway" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = "${
    merge(var.tags, map("Name", format("%s", var.name)))
  }"
}

resource "aws_vpc_dhcp_options" "dhcp_opts" {
  count = "${length(var.dhcp_options_domain_name) > 0 ? 1 : 0}"
  domain_name = "${var.dhcp_options_domain_name}"
  tags = "${
    merge(var.tags, map("Name", format("%s", var.name)
      ))
  }"
}

resource "aws_route_table" "public_access" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = "${
    merge(var.tags, map("Name", format("%s-public-%d", var.name)))
  }"
}

resource "aws_route_table" "nat_access" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = "${ merge(var.tags, map("Name", format("%s-nat-%d", var.name )))
  }"
}

resource "aws_route_table" "internal_access" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = "${
    merge(var.tags, map("Name", format("%s-private-%d", var.name)))
  }"
}
resource "aws_route" "public_internet" {
  route_table_id = "${aws_route_table.public_access.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.public.id}"
}
# For internal communication, routing to a network interface
#resource "aws_route" "internal_route" {
#  route_table_id = "${aws_route_table.public_net.id}"
#  destination_cidr_block = "0.0.0.0/0"
#  gateway_id = "${aws_network.igw.id}"
#}
resource "aws_route" "nat_access" {
  count = "${var.enable_nat}"
  route_table_id = "${aws_route_table.nat_access.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.amazon_nat_device.id}"
}
resource "aws_eip" "amazon_nat_device" {
  #count = "${var.enable_nat ? length(var.enabled_az_list) : 0}"
  vpc      = true
  depends_on = ["aws_internet_gateway.public"]
}

resource "aws_nat_gateway" "amazon_nat_device" {
  allocation_id = "${aws_eip.amazon_nat_device.id}"
  subnet_id = "${element(aws_subnet.presentation_subnets.*.id, 1)}"
  depends_on    = [
    "aws_internet_gateway.public",
    "aws_eip.amazon_nat_device",
    "aws_subnet.presentation_subnets"
  ]
  tags {
    access-role = "partial" #partial, because they can access the internet, but only through the NATing device
  }
}

resource "aws_route_table_association" "database_join" {
  count = "${length(var.enabled_az_list)}"
  subnet_id     = "${element(aws_subnet.database_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.internal_access.id}"
}
resource "aws_route_table_association" "data_comm_join" {
  count = "${length(var.enabled_az_list)}"
  subnet_id     = "${element(aws_subnet.data_comm_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.internal_access.id}"
}
resource "aws_route_table_association" "secret_join" {
#  count         = "${length(aws_subnet.secret_subnets)}"
  count = "${length(var.enabled_az_list)}"
  subnet_id      = "${element(aws_subnet.secret_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.internal_access.id}"
}
resource "aws_route_table_association" "admin_join" {
  count = "${length(var.enabled_az_list)}"
  subnet_id     = "${element(aws_subnet.admin_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.nat_access.id}"
}
resource "aws_route_table_association" "application_join" {
  count = "${length(var.enabled_az_list)}"
  subnet_id     = "${element(aws_subnet.application_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.nat_access.id}"
}
resource "aws_route_table_association" "presentation_join" {
  count = "${length(var.enabled_az_list)}"
  subnet_id     = "${element(aws_subnet.presentation_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_access.id}"
}

resource "aws_subnet" "admin_subnets" {
  count = "${length(var.enabled_az_list)}"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"
  ipv6_cidr_block = "${cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, "8", count.index + lookup(var.subnet_legend,"admin"))}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, "8", lookup(var.subnet_legend,"admin") + count.index)}"
  tags = "${
    merge(var.tags, map(
      "Name", format("%s-%d", "admin", count.index ),
      "access-role", "internal",
      "route-group", "proxy"
    ))
  }"
}
resource "aws_subnet" "data_comm_subnets" {
  count = "${length(var.enabled_az_list)}"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"
  ipv6_cidr_block = "${cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, "8", count.index + lookup(var.subnet_legend,"data_comm"))}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, "8", lookup(var.subnet_legend,"data_comm") + count.index)}"
  tags = "${
    merge(var.tags, map(
      "Name", format("%s-%d", "data_comm", count.index ),
      "access-role", "internal"
    ))
  }"
}
resource "aws_subnet" "database_subnets" {
  count = "${length(var.enabled_az_list)}"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"
  ipv6_cidr_block = "${cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, "8", count.index + lookup(var.subnet_legend,"database"))}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, "8", lookup(var.subnet_legend,"database") + count.index)}"
  tags = "${
    merge(var.tags, map(
      "Name", format("%s-%d", "database", count.index ),
      "access-role", "internal"
    ))
  }"
}
resource "aws_subnet" "secret_subnets" {
  count = "${length(var.enabled_az_list)}"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"
  ipv6_cidr_block = "${cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, "8", count.index + lookup(var.subnet_legend,"secret"))}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, "8", lookup(var.subnet_legend,"secret") + count.index)}"
  tags = "${
    merge(var.tags, map(
      "Name", format("%s-%d", "secret", count.index ),
      "access-role", "internal"
    ))
  }"
}
resource "aws_subnet" "application_subnets" {
  count = "${length(var.enabled_az_list)}"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"
  ipv6_cidr_block = "${cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, "8", count.index + lookup(var.subnet_legend,"application"))}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, "8", lookup(var.subnet_legend,"application") + count.index)}"
  tags = "${
    merge(var.tags, map(
      "Name", format("%s-%d", "application", count.index ),
      "access-role", "public",
      "route-group", "nat"
    ))
  }"
}
resource "aws_subnet" "presentation_subnets" {
  count = "${length(var.enabled_az_list)}"
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"
  ipv6_cidr_block = "${cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, "8", count.index + lookup(var.subnet_legend,"presentation"))}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, "8", lookup(var.subnet_legend,"presentation") + count.index)}"
  tags = "${
    merge(var.tags, map(
      "Name", format("%s-%d", "presentation", count.index ),
      "access-role", "public"
    ))
  }"
}

resource "aws_network_acl" "main" {
  vpc_id = "${aws_vpc.vpc.id}"
}

/*  resource "aws_network_acl_rule" "mysql_outbound" {
  #cross az traffic might fail, I don't need this, just want to add it
  network_acl_id = "${aws_network_acl.main.id}"
  count = "${length(var.enabled_az_list)}"
  egress  = true
  protocol    = "tcp"
  rule_number = "${ 200 + count.index}"
  rule_action = "allow"
  cidr_block  = "${element(aws_subnet.data_comm_subnets.*.cidr_block, count.index)}"
  from_port   = 3306
  to_port     = 3306
}
resource "aws_network_acl_rule" "mysql_inbound" {
  #cross az traffic might fail, I don't need this, just want to add it
  network_acl_id = "${aws_network_acl.main.id}"
  count       = "${length(var.enabled_az_list)}"
  egress      = true
  protocol    = "tcp"
  rule_number = "${ 100 + count.index}"
  rule_action = "allow"
  cidr_block  = "${element(aws_subnet.database_subnets.*.cidr_block, count.index)}"
  from_port   = 3306
  to_port     = 3306
}  */
resource "aws_security_group" "common" {
  name        = "common"
  description = "applied on all machines"
  vpc_id      = "${aws_vpc.vpc.id}"
}
resource "aws_security_group" "lb-http" {
  name        = "lb-http"
  description = "lb access"
  vpc_id      = "${aws_vpc.vpc.id}"
}
resource "aws_security_group" "db" {
  name        = "database-access"
  description = "client access to databases"
  vpc_id      = "${aws_vpc.vpc.id}"
}
resource "aws_security_group" "jumphost" {
  name        = "jumphost-only"
  description = "jump from here elsewhere in the alan"
  vpc_id      = "${aws_vpc.vpc.id}"
}

resource "aws_security_group_rule" "jumphost_access_22223" {
  type              = "ingress"
  from_port         = 22223
  to_port           = 22223
  protocol          = "tcp"
  source_security_group_id = "${aws_security_group.jumphost.id}"
  security_group_id = "${aws_security_group.common.id}"
  description       = "KevinFaulkner SSH access from home"
}
resource "aws_security_group_rule" "jumphost_access_kevin" {
  type              = "ingress"
  from_port         = 22223
  to_port           = 22223
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jumphost.id}"
  description       = "KevinFaulkner SSH access from home"
}
resource "aws_security_group_rule" "jumphost_access_ssh_kevin_initial" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["75.182.231.50/32"]
  security_group_id = "${aws_security_group.jumphost.id}"
  description       = "KevinFaulkner SSH access from home"
}
resource "aws_security_group" "personal_access" {
  name        = "access for individuals, on rule description, write username"
  description = "applied on all machines"
  vpc_id      = "${aws_vpc.vpc.id}"
}

resource "aws_security_group_rule" "individual_access_ssh_kevin" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["75.182.231.50/32"]
  security_group_id = "${aws_security_group.personal_access.id}"
  description       = "KevinFaulkner SSH access from home"
}
resource "aws_security_group_rule" "allow_jumphost_to_common" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.jumphost.id}"
  security_group_id        = "${aws_security_group.common.id}"
  description              = "allow ssh from the jumphost"
}
resource "aws_security_group_rule" "jumphost_to_common" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.common.id}"
  security_group_id        = "${aws_security_group.jumphost.id}"
  description              = "allow ssh from the jumphost"
}
resource "aws_security_group" "kube" {
  name        = "kubernetes"
  description = "building out a cluster"
  vpc_id      = "${aws_vpc.vpc.id}"
}

resource "aws_security_group_rule" "https_egress" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kube.id}"
  description       = "allow for yum updates and more"
}
resource "aws_security_group_rule" "http_egress" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kube.id}"
  description       = "allow for yum updates and more"
}
