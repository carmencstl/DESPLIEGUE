/* ---------VARIABLES---------- */

variable "instance_type" {
    type = string
    default = "t2.small"
}

variable "version_ubuntu" {
    type = string
    default = "jammy-22.04"
}

variable "key_name" {
  type = string
  default = "vockey"
}

variable "weServer_name" {
  type = string
  default = "Web Server"
}

variable "region" {
  type =  string
    default = "us-east-1"
}

variable "zone_name"{
    type = string
    default = "carmencastillogaitan.com"
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

data "aws_vpc" "default" {
    default = true
    region = var.region
}


