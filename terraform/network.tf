resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "kubeadm-nat-eip"
  }
}

resource "aws_nat_gateway" "public" {
  allocation_id = aws_eip.nat.id
  subnet_id     = module.subnet_a.id

  tags = {
    Name = "kubeadm-nat"
  }

  depends_on = [module.vpc]
}

resource "aws_route_table" "private" {
  vpc_id = module.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public.id
  }

  tags = {
    Name = "kubeadm-private-rt"
  }
}

resource "aws_route_table" "isolated" {
  vpc_id = module.vpc.id

  tags = {
    Name = "kubeadm-isolated-rt"
  }
}

resource "aws_eip" "bastion" {
  domain = "vpc"

  tags = {
    Name = "kubeadm-bastion-eip"
  }
}

resource "aws_eip_association" "bastion" {
  allocation_id = aws_eip.bastion.id
  instance_id   = module.bastion.id
}

resource "aws_eip" "public_worker" {
  domain = "vpc"

  tags = {
    Name = "kubeadm-public-worker-eip"
  }
}

resource "aws_eip_association" "public_worker" {
  allocation_id = aws_eip.public_worker.id
  instance_id   = module.public_worker.id
}
