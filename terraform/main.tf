provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "./modules/vpc"
}

module "subnet_a" {
  source                = "./modules/subnet"
  vpc_id                = module.vpc.id
  cidr                  = "10.0.1.0/24"
  az                    = data.aws_availability_zones.available.names[0]
  name                  = "subnet-a"
  public                = true
  public_route_table_id = module.vpc.public_route_table_id
}

module "subnet_b" {
  source                = "./modules/subnet"
  vpc_id                = module.vpc.id
  cidr                  = "10.0.2.0/24"
  az                    = data.aws_availability_zones.available.names[1]
  name                  = "subnet-b"
  public                = true
  public_route_table_id = module.vpc.public_route_table_id
}

module "security" {
  source           = "./modules/security"
  vpc_id           = module.vpc.id
  ssh_allowed_cidr = var.ssh_allowed_cidr
}