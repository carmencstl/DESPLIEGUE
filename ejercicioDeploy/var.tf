variable "deploy_instance_type" {
  type    = string
  default = "t2.small"
}

variable "key_name" {
  type    = string
  default = "vockey"
}

variable "deploy_name" {
  type    = string
  default = "Deploy"
}

variable "ubuntu_version" {
  type    = string
  default = "jammy-22.04"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  type    = string
  default = "bucket-terraform-github-actions"
}

variable "security_name_deploy" {
  type = string
  default = "grupo_Deploy"
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
