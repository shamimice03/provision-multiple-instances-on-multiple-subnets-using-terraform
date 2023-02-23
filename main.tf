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
    "Team" = "Platform-team"
    "Env"  = "test"
  }

}

################## Create Security Group ################## 
resource "aws_security_group" "public_sg" {
  name        = "allow_public_access"
  description = "Allow SSH from Anywhere"

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

################## Create Security Group ################## 
resource "aws_security_group" "private_sg" {
  name        = "allow_from_public_instnaces"
  description = "Allow SSH from public instances only"

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

################## Create AWS EC2 Instance with "Amozon linux" AMI ################## 
resource "aws_instance" "public_hosts" {
  count         = var.amazon_linux_host_count
  ami           = data.aws_ami.amazon_linux_ami.id
  instance_type = var.instance_type
  #subnet_id = module.vpc.pu
  key_name               = aws_key_pair.aws_ec2_access_key.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]

  tags = {
    "Name" = "public-instance-${count.index + 1}"

  }
}


