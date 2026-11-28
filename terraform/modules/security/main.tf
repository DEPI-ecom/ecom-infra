resource "aws_security_group" "bastion" {
  name_prefix = "kubeadm-bastion-"
  vpc_id      = var.vpc_id

  tags = {
    Name = "bastion-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = var.ssh_allowed_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "bastion_out" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "nodes" {
  name_prefix = "kubeadm-nodes-"
  vpc_id      = var.vpc_id

  tags = {
    Name = "kubeadm-nodes-sg"
  }
}

# SSH to nodes only from the bastion, not from the internet.
resource "aws_vpc_security_group_ingress_rule" "nodes_ssh" {
  security_group_id            = aws_security_group.nodes.id
  referenced_security_group_id = aws_security_group.bastion.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "nodes_flannel" {
  security_group_id            = aws_security_group.nodes.id
  referenced_security_group_id = aws_security_group.nodes.id
  from_port                    = 8472
  to_port                      = 8472
  ip_protocol                  = "udp"
}

resource "aws_vpc_security_group_ingress_rule" "nodes_kubelet" {
  security_group_id            = aws_security_group.nodes.id
  referenced_security_group_id = aws_security_group.nodes.id
  from_port                    = 10250
  to_port                      = 10250
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "nodes_exporter" {
  security_group_id            = aws_security_group.nodes.id
  referenced_security_group_id = aws_security_group.nodes.id
  from_port                    = 9100
  to_port                      = 9100
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "nodes_out" {
  security_group_id = aws_security_group.nodes.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "control_plane" {
  name_prefix = "kubeadm-control-plane-"
  vpc_id      = var.vpc_id

  tags = {
    Name = "kubeadm-control-plane-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "control_plane_api" {
  security_group_id            = aws_security_group.control_plane.id
  referenced_security_group_id = aws_security_group.nodes.id
  from_port                    = 6443
  to_port                      = 6443
  ip_protocol                  = "tcp"
}

resource "aws_security_group" "public_ingress" {
  name_prefix = "kubeadm-public-ingress-"
  vpc_id      = var.vpc_id

  tags = {
    Name = "kubeadm-public-ingress-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "public_web" {
  for_each = toset(["80", "443"])

  security_group_id = aws_security_group.public_ingress.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = tonumber(each.key)
  to_port           = tonumber(each.key)
  ip_protocol       = "tcp"
}
