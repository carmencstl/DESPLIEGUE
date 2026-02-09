variable "web_server_instance_type" {
  type    = string
  default = "t2.large"
}

variable "bastion_instance_type"{
   type    = string
  default = "t2.medium"
}

variable "key_name" {
  type    = string
  default = "vockey"
}

variable "frontend_name" {
  type    = string
  default = "Frontend"
}

variable "bastion_name" {
  type    = string
  default = "Bastion"
}

variable "api_name" {
  type    = string
  default = "API"
}

variable "images_name" {
  type    = string
  default = "Images"
}

variable "ubuntu_version" {
  type    = string
  default = "jammy-22.04"
}

variable "region" {
  type    = string
  default = "us-east-1"
}


variable "zone_name" {
  type    = string
  default = "carmencastillogaitan.net"
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
