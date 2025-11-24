terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.21.0"
    }
  }
  required_version = ">= 1.2"
}

provider "aws" {
  region = "us-east-1"
}

/* WEB SERVER */
resource "aws_instance" "WebServer" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.WebServer.id]
  key_name                    = var.key_name
  tags = {
    Name = var.weServer_name
  }
  user_data                   = file("install_apache_php.sh")
  user_data_replace_on_change = true
}


resource "aws_security_group" "WebServer" {
  name        = "grupo_WebServer"
  description = "SSH and HTTP"
  tags = {
    Name = "grupo_WebServer"
  }
}

resource "aws_vpc_security_group_ingress_rule" "WebServer_allow_http_ipv4" {
  security_group_id = aws_security_group.WebServer.id 
  cidr_ipv4         = "0.0.0.0/0"
    from_port         = 80
    ip_protocol       = "tcp"
    to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "WebServer_allow_all" {
  security_group_id = aws_security_group.WebServer.id 
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


resource "aws_route53_zone" "mainzone" {
    name = var.zone_name
  vpc {
    vpc_id = data.aws_vpc.default.id
    vpc_region = var.region
  }
}

resource "aws_route53_record" "webServer" {
    type = "A"
    name = var.zone_name
    zone_id = aws_route53_zone.mainzone.zone_id
    ttl = "300" 
    records = [aws_instance.WebServer.private_ip]
}

resource "aws_route53_record" "name" {
    type = "CNAME"
    name = "www.${var.zone_name}"
    zone_id = aws_route53_zone.mainzone.zone_id
    ttl = "300"
    records = [aws_route53_record.webServer.name]
}