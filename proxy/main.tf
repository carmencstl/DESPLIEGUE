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
  region = var.region
}


resource "aws_instance" "FrontEnd" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.FrontEnd.id]
  key_name               = var.key_name
  tags = {
    Name = var.frontend_name
  }
  user_data                   = templatefile("scripts/install_apache.tftpl", {backendip=aws_instance.BackEnd.private_ip})
  user_data_replace_on_change = true

}


/* -------------GRUPO DE SEGURIDAD FRONT------------- */
resource "aws_security_group" "FrontEnd" {
  name        = "FrontEnd_SG"
  description = "Grupo Seguridad FrontEnd "
  tags = {
    name = "FrontEnd_SG"
  }
}

/* ----------REGLAS DE ENTRADA Y SALIDA FRONT---------- */
resource "aws_vpc_security_group_ingress_rule" "FrontEnd_allow_http_ipv4" {
  security_group_id = aws_security_group.FrontEnd.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "entrada_ssh_frontend" {
  security_group_id            = aws_security_group.FrontEnd.id
  referenced_security_group_id = aws_security_group.Bastion.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}


resource "aws_vpc_security_group_egress_rule" "FrontEnd_allow_all" {
  security_group_id = aws_security_group.FrontEnd.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

}

resource "aws_instance" "BackEnd" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.BackEnd.id]
  key_name               = var.key_name
  tags = {
    Name = var.backend_name
  }
  user_data                   = file("scripts/install_apache_php.sh")
  user_data_replace_on_change = true

}

/* -------------GRUPO DE SEGURIDAD BACK------------- */
resource "aws_security_group" "BackEnd" {
  name        = "BackEnd_SG"
  description = "Grupo Seguridad BackEnd "
  tags = {
    name = "BackEnd_SG"
  }
}

/* ----------REGLAS DE ENTRADA Y SALIDA BACK---------- */
resource "aws_vpc_security_group_ingress_rule" "entrada_http_frontend" {
  security_group_id            = aws_security_group.BackEnd.id
  referenced_security_group_id = aws_security_group.FrontEnd.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_ingress_rule" "entrada_ssh_backend" {
  security_group_id            = aws_security_group.BackEnd.id
  referenced_security_group_id = aws_security_group.Bastion.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}



resource "aws_vpc_security_group_egress_rule" "BackEnd_allow_all" {
  security_group_id = aws_security_group.BackEnd.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


resource "aws_instance" "Bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.Bastion.id]
  key_name               = var.key_name
  tags = {
    Name = var.bastion_name
  }
  user_data                   = file("scripts/install_apache.sh")
  user_data_replace_on_change = true

}

/* -------------GRUPO DE SEGURIDAD BASTION------------- */
resource "aws_security_group" "Bastion" {
  name        = "Bastion_SG"
  description = "Grupo Seguridad Bastion "
  tags = {
    name = "Bastion_SG"
  }
}

/* ----------REGLAS DE ENTRADA Y SALIDA BASTION---------- */
resource "aws_vpc_security_group_ingress_rule" "Bastion_allow_ssh_ipv4" {
  security_group_id = aws_security_group.Bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "Bastion_allow_all" {
  security_group_id = aws_security_group.Bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

/* -------------ROUTE53------------- */
resource "aws_route53_zone" "mainzone" {
  name = var.zone_name
  vpc {
    vpc_id     = data.aws_vpc.default.id
    vpc_region = var.region
  }
}

resource "aws_route53_record" "FrontEnd_record" {
  type    = "A"
  name    = "fe.${var.zone_name}"
  zone_id = aws_route53_zone.mainzone.zone_id
  ttl     = "300"
  records = [aws_instance.FrontEnd.private_ip]
}

resource "aws_route53_record" "BackEnd_record" {
  type    = "A"
  name    = "be.${var.zone_name}"
  zone_id = aws_route53_zone.mainzone.zone_id
  ttl     = "300"
  records = [aws_instance.BackEnd.private_ip]
}

/*-------------IP ELASTICA FRONTEND-------------*/
resource "aws_eip" "ip_elastica_frontend" {
  instance = aws_instance.FrontEnd.id
  domain   = "vpc"
}

/*-------------IP ELASTICA BASTION-------------*/
resource "aws_eip" "ip_elastica_bastion" {
  instance = aws_instance.Bastion.id
  domain   = "vpc"
}