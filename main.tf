################## Create VPC  ################## 
module "vpc" {

  source = "github.com/shamimice03/terraform-aws-vpc"

  vpc_name = "test_vpc"
  cidr     = "192.168.0.0/16"

  azs                 = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  public_subnet_cidr  = ["192.168.0.0/20", "192.168.16.0/20", "192.168.32.0/20"]
  private_subnet_cidr = ["192.168.48.0/20", "192.168.64.0/20"]

  enable_dns_hostnames      = true
  enable_dns_support        = true
  enable_single_nat_gateway = false

  tags = {
    "Team" = "platform-team"
    "Env"  = "test"
  }

}

################## Local Variables  ################## 
locals {
  public_subnets  = module.vpc.public_subnet_id
  private_subnets = module.vpc.private_subnet_id
  vpc_id          = module.vpc.vpc_id

  public_instance_conf = [
    for index, subnet in local.public_subnets : [
      for i in range(var.public_instance_per_subnet) : {
        ami                    = data.aws_ami.amazon_linux_ami.id
        instance_type          = var.instance_type
        subnet_id              = subnet
        key_name               = aws_key_pair.aws_ec2_access_key.id
        vpc_security_group_ids = [aws_security_group.public_sg.id]
      }
    ]
  ]

  private_instance_conf = [
    for index, subnet in local.private_subnets : [
      for i in range(var.private_instance_per_subnet) : {
        ami                    = data.aws_ami.amazon_linux_ami.id
        instance_type          = var.instance_type
        subnet_id              = subnet
        key_name               = aws_key_pair.aws_ec2_access_key.id
        vpc_security_group_ids = [aws_security_group.private_sg.id]
      }

    ]
  ]

  public_instance  = flatten(local.public_instance_conf)
  private_instance = flatten(local.private_instance_conf)
}

################## Create Security Group for Public Instances  ################## 
resource "aws_security_group" "public_sg" {
  name        = "allow_public_access"
  description = "Allow Traffic from Anywhere"
  vpc_id      = local.vpc_id

  dynamic "ingress" {

    for_each = var.public_instance_sg_ports
    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "public_sg"
  }
}

################## Create Security Group for Private Instances  ################## 
resource "aws_security_group" "private_sg" {
  name        = "allow_from_public_instnaces"
  description = "Allow traffice from public instance sg only"
  vpc_id      = local.vpc_id

  dynamic "ingress" {

    for_each = var.private_instance_sg_ports
    content {
      from_port       = ingress.value["port"]
      to_port         = ingress.value["port"]
      protocol        = ingress.value["protocol"]
      security_groups = [aws_security_group.public_sg.id]
    }
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.public_sg.id]
  }

  tags = {
    "Name" = "private_sg"
  }
}

################## SSH key generation ################## 
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

################## Extracting private key ################## 
resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = var.private_key_location
  file_permission = "0400"
}

################## Create AWS key pair ################## 
resource "aws_key_pair" "aws_ec2_access_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh.public_key_openssh
}

################## Create AWS EC2 Instance on Public Subnet ################ 
resource "aws_instance" "public_hosts" {
  for_each               = { for key, value in local.public_instance : key => value }
  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  key_name               = each.value.key_name
  vpc_security_group_ids = each.value.vpc_security_group_ids
  tags = {
    "Name" = "public-instance-${each.key}"
  }
}

################## Create AWS EC2 Instance on Private Subnet ################ 
resource "aws_instance" "private_hosts" {
  for_each               = { for key, value in local.private_instance : key => value }
  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  key_name               = each.value.key_name
  vpc_security_group_ids = each.value.vpc_security_group_ids
  tags = {
    "Name" = "private-instance-${each.key}"
  }
}
