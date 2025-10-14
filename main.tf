terraform {
    backend "s3"{
        bucket = "s3://webCarmen"
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

//ASI SE HACE UN GRUPO DE SEGURIDAD
resource "aws_security_group" "ejer_1_Carmen" {
  name        = "ejer_1_Carmen"
  description = "Permitir HTTP y SSH"

  tags = {
    Name = "ejer_1_Carmen"
  }
}

//GRUPOS DE SEGURIDAD DE ENTRADA EN 22 Y 80

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.ejer_1_Carmen.id  
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.ejer_1_Carmen.id  
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all"{
  security_group_id = aws_security_group.ejer_1_Carmen.id 
  cidr_ipv4 = "0.0.0.0/0" // cualquier direccion
  ip_protocol = "-1" //esto significa cualquier protocolo, esto nos hace que from y to port sean opcionales. 

}


//Asi se hace una instancia
resource "aws_instance" "ejer_1_Carmen" { //recurso y nombre
  ami             = "ami-0bbdd8c17ed981ef9" //ami o imagen del SO
  instance_type   = "t2.small" //Tamaño 
  vpc_security_group_ids = [aws_security_group.ejer_1_Carmen.id] //Grupos de seguridad
  //claves SSH
  key_name = "vockey"
  tags = {
    Name = "instancia_ejer1" 
  }
  user_data = file("scripts/install_apache.sh")
}




