terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.2"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "Bastion" {
  ami                    = "ami-0bbdd8c17ed981ef9"
  instance_type          = "t2.small"
  vpc_security_group_ids = [aws_security_group.Bastion.id]
  key_name               = "vockey"
  tags = {
    Name = "Bastion"
  }
}

resource "aws_security_group" "Bastion" {
  name        = "grupo_Bastion"
  description = "SSH"
  tags = {
    Name = "grupo_Bastion"
  }
}

resource "aws_vpc_security_group_ingress_rule" "Bastion_allow_ssh_ipv4" {
  security_group_id = aws_security_group.Bastion.id 
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.Bastion.id 
  cidr_ipv4         = "0.0.0.0/0" 
  ip_protocol       = "-1" 
}

resource "aws_instance" "WebServer-ex" {
  ami                         = "ami-0bbdd8c17ed981ef9"
  instance_type               = "t2.large"
  vpc_security_group_ids      = [aws_security_group.WebServer-ex.id]
  key_name                    = "vockey"
  tags = {
    Name = "WebServer-ex"
  }
  user_data                   = file("scripts/install_apache_php.sh")
  user_data_replace_on_change = true
}

resource "aws_security_group" "WebServer-ex" {
  name        = "grupo_WebServer-ex"
  description = "Permitir HTTP y SSH Bastion"
  tags = {
    Name = "grupo_WebServer-ex"
  }
}

resource "aws_vpc_security_group_ingress_rule" "WebServer-ex_allow_http_ipv4" {
  security_group_id = aws_security_group.WebServer-ex.id  
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "entrada_ssh_bastion" {
  security_group_id            = aws_security_group.WebServer-ex.id
  referenced_security_group_id = aws_security_group.Bastion.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_WebServer" {
  security_group_id = aws_security_group.WebServer-ex.id 
  cidr_ipv4         = "0.0.0.0/0" 
  ip_protocol       = "-1" 
}

resource "aws_eip" "ip_elastica_webServer" {
  instance = aws_instance.WebServer-ex.id
  domain   = "vpc"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_route53_zone" "mainzone" {
  name = "carmencastillogaitan.com"
  vpc {
    vpc_id = data.aws_vpc.default.id
    vpc_region = "us-east-1"
  }
}

resource "aws_route53_record" "web" {
  zone_id = aws_route53_zone.mainzone.zone_id
  name    = "web.carmencastillogaitan.com"
  type    = "A"
  ttl     = 300
  records = [aws_instance.WebServer-ex.private_ip]
}

