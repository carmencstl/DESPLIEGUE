terraform {
    backend "s3"{
        key = "ejer1.tfstate"
        bucket = "web-carmen"
        region = "us-east-1"
    }
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

 resource "aws_instance" "FrontEnd" { //recurso y nombre
  ami             = "ami-0bbdd8c17ed981ef9" //ami o imagen del SO
  instance_type   = "t2.small" //Tamaño 
  vpc_security_group_ids = [aws_security_group.FrontEnd.id] //Grupos de seguridad
  //claves SSH
  key_name = "vockey"
  tags = {
    Name = "instancia_frontend" 
  }
  user_data = file("scripts/install_apache_php.sh")
  user_data_replace_on_change = true
}


resource "aws_instance" "BBDD" { //recurso y nombre
  ami             = "ami-0bbdd8c17ed981ef9" 
  instance_type   = "t2.small" //Tamaño 
  vpc_security_group_ids = [aws_security_group.BBDD.id] //Grupos de seguridad
  //claves SSH
  key_name = "vockey"
  tags = {
    Name = "instancia_bbdd" 
  }
  user_data = file("scripts/install_mySQL.sh")
  user_data_replace_on_change = true
}


resource "aws_security_group" "FrontEnd" {
  name        = "grupo_Front"
  description = "Permitir HTTP y SSH"

  tags = {
    Name = "grupo_Front"
  }
}

resource "aws_vpc_security_group_ingress_rule" "front_allow_ssh_ipv4" {
  security_group_id = aws_security_group.FrontEnd.id  
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "front_allow_http_ipv4" {
  security_group_id = aws_security_group.FrontEnd.id  
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all"{
  security_group_id = aws_security_group.FrontEnd.id 
  cidr_ipv4 = "0.0.0.0/0" 
  ip_protocol = "-1" 
}


resource "aws_security_group" "BBDD" {
  name        = "grupo_BBDD"
  description = "Para BBDD"

  tags = {
    Name = "grupo_BBDD"
  }
}

resource "aws_vpc_security_group_ingress_rule" "bbdd_allow_ssh_ipv4" {
  security_group_id = aws_security_group.BBDD.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "front_bbdd_entrada" {
  security_group_id = aws_security_group.BBDD.id
  referenced_security_group_id = aws_security_group.FrontEnd.id
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_vpc_security_group_egress_rule" "bbdd_allow_all"{
  security_group_id = aws_security_group.BBDD.id 
  cidr_ipv4 = "0.0.0.0/0" 
  ip_protocol = "-1" 
}

