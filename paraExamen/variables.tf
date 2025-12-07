variable "instance_type" {
  type    = string
  default = "t2.small"
}

variable "key_name" {
  type    = string
  default = "vockey"
}

variable "frontend_name" {
  type    = string
  default = "FrontEnd"
}

variable "ubuntu_version" {
  type    = string
  default = "jammy-22.04"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "backend_name" {
  type    = string
  default = "BackEnd"
}

variable "zone_name" {
  type    = string
  default = "carmencastillogaitan.com"
}

variable "bastion_name" {
  type    = string
  default = "Bastion"
}

/* -------------DATA------------- */
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-${var.ubuntu_version}-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_vpc" "default" {
  default = true
  region  = var.region
}
