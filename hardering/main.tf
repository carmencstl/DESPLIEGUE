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

resource "aws_instance" "Front" {
  ami                    = "ami-0bbdd8c17ed981ef9"
  instance_type          = "t2.small"
  vpc_security_group_ids = [aws_security_group.Front.id]
  key_name               = "vockey"
  tags = {
    Name = "Front"
  }
}

resource "aws_security_group" "Front" {
  name        = "grupo_Front"
  description = "SSH and HTTP"
  tags = {
    Name = "grupo_Front"
  }
}

