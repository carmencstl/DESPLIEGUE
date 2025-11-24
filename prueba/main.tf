terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.14.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "terraFull" {
  ami           = "ami-0bbdd8c17ed981ef9" # Ubuntu 22.04
  instance_type = "t2.medium"
  key_name      = "vockey"
  user_data     = file("install_full.sh")

  vpc_security_group_ids = [aws_security_group.terraFull.id]

  tags = {
    Name = "terraFull"
  }
}

resource "aws_security_group" "terraFull" {
  name        = "terraFull_SG"
  description = "FullSecurityGroup"
}

# Permitir SSH
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.terraFull.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# Permitir HTTP
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.terraFull.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# Salida Todos
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.terraFull.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
    