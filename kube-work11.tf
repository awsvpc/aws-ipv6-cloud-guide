resource "aws_security_group" "kube_master" {
  name        = "kube-master"
  description = "kubernetes master node"
  vpc_id      = "${aws_vpc.vpc.id}"
}

resource "aws_security_group_rule" "master_kublet_api" {
  type                     = "ingress"
  from_port                = 2379
  to_port                  = 2380
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.kube_master.id}"
  source_security_group_id = "${aws_security_group.kube_client_worker.id}"
  description              = "etcd client server communication, also kube-apiserver"
}
resource "aws_security_group_rule" "master_kube_api" {
  type                     = "ingress"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.kube_master.id}"
  security_group_id        = "${aws_security_group.kube_client_worker.id}"
  description              = ""
}
resource "aws_security_group_rule" "control_pane_kubelet" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10252
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.kube_client_worker.id}"
  security_group_id        = "${aws_security_group.kube_master.id}"
  description              = "10250 kubelet api, 1 kube scheduler, 2 kube-controller-manager"
}

resource "aws_security_group" "kube" {
  name        = "kubernetes"
  description = "building out a cluster"
  vpc_id      = "${aws_vpc.vpc.id}"
}

resource "aws_security_group" "kube_client_worker" {
  name        = "kubernetes-worker"
  description = "kubernetes client worker"
  vpc_id      = "${aws_vpc.vpc.id}"
}

resource "aws_security_group_rule" "kubelet_api" {
  type              = "egress"
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  security_group_id = "${aws_security_group.kube_client_worker.id}"
  source_security_group_id = "${aws_security_group.kube_master.id}"
  description       = "allow for yum updates and more"
}

resource "aws_security_group_rule" "" {
  type              = "egress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  security_group_id = "${aws_security_group.kube_client_worker.id}"
  source_security_group_id = "${aws_security_group.kube_master.id}"
  description       = "allow for general purpose usage of web apps"
}
resource "aws_network_interface" "kube_master" {
  subnet_id   = "${aws_subnet.admin_subnets.1.id}"
  private_ips = ["10.200.62.11"]
  security_groups = [
    "${aws_security_group.kube_master.id}",
    "${aws_security_group.common.id}"
  ]
  tags = {
    purpose = "kube-master"
  }
}

resource "aws_eip" "kube_master" {
  vpc   = true
  associate_with_private_ip = "10.200.62.11"
  tags = {
    purpose = "kube-master"
  }
}
