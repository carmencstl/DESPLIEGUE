variable "region" {
    type=string
    default = "us-east-1"
}

variable "key_name" {
  type = string
  default = "vockey"
}

variable "instance_type" {
    type = string
    default = "t2.medium"
}

variable "any_ip" {
  type = string
  default = "0.0.0.0/0"
}

variable "version_ubuntu" {
  type = string
  default = "jammy-22.04"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-${var.version_ubuntu}-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

//en registry es de ec2
data "aws_vpc" "defaultNetwork" {
  default = true
  region= var.region
}

variable "zone_name" {
  type = string
  default = "practicaCompleta.org"
}