provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

module "vpc" {
  source = "./modules/vpc"
}

module "subnet_a" {
  source         = "./modules/subnet"
  vpc_id         = module.vpc.id
  cidr           = "10.0.1.0/24"
  az             = data.aws_availability_zones.available.names[0]
  name           = "subnet-a"
  public         = true
  route_table_id = module.vpc.public_route_table_id
}

module "subnet_b" {
  source         = "./modules/subnet"
  vpc_id         = module.vpc.id
  cidr           = "10.0.2.0/24"
  az             = data.aws_availability_zones.available.names[1]
  name           = "subnet-b"
  route_table_id = aws_route_table.private.id
}

module "subnet_isolated" {
  source         = "./modules/subnet"
  vpc_id         = module.vpc.id
  cidr           = "10.0.3.0/24"
  az             = module.subnet_b.availability_zone
  name           = "subnet-isolated"
  route_table_id = aws_route_table.isolated.id
}

module "security" {
  source           = "./modules/security"
  vpc_id           = module.vpc.id
  ssh_allowed_cidr = var.ssh_allowed_cidr
}

module "control_plane" {
  source             = "./modules/ec2"
  name               = "control-plane"
  ami                = data.aws_ssm_parameter.ami.value
  subnet_id          = module.subnet_a.id
  security_group_ids = [module.security.nodes_sg_id, module.security.control_plane_sg_id]
  key_name           = var.key_name
  instance_type      = "t3.small"
  public_ip          = true
}

module "worker_1" {
  source             = "./modules/ec2"
  name               = "worker-1"
  ami                = data.aws_ssm_parameter.ami.value
  subnet_id          = module.subnet_b.id
  security_group_ids = [module.security.nodes_sg_id]
  key_name           = var.key_name
  instance_type      = "t3.small"
}

module "worker_2" {
  source             = "./modules/ec2"
  name               = "worker-2"
  ami                = data.aws_ssm_parameter.ami.value
  subnet_id          = module.subnet_b.id
  security_group_ids = [module.security.nodes_sg_id]
  key_name           = var.key_name
  instance_type      = "t3.small"
}

module "public_worker" {
  source             = "./modules/ec2"
  name               = "public-worker"
  ami                = data.aws_ssm_parameter.ami.value
  subnet_id          = module.subnet_a.id
  security_group_ids = [module.security.nodes_sg_id, module.security.public_ingress_sg_id]
  key_name           = var.key_name
  instance_type      = "t3.small"
  public_ip          = true
}

module "db_worker" {
  source             = "./modules/ec2"
  name               = "db-worker"
  ami                = var.db_ami_id
  subnet_id          = module.subnet_isolated.id
  security_group_ids = [module.security.nodes_sg_id]
  key_name           = var.key_name
  instance_type      = "t3.small"
}

module "bastion" {
  source             = "./modules/ec2"
  name               = "bastion"
  ami                = data.aws_ssm_parameter.ami.value
  subnet_id          = module.subnet_a.id
  security_group_ids = [module.security.bastion_sg_id]
  key_name           = var.key_name
  public_ip          = true
}
