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
  region = var.region
}

/* INSTANCIA BASTION */

resource "aws_instance" "Bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.bastion_instance_type
  vpc_security_group_ids = [aws_security_group.Bastion-SG.id]
  key_name               = var.key_name
  tags = {
    Name = var.bastion_name
  }
}

/* GRUPO DE SEGURIDAD BASTION */

resource "aws_security_group" "Bastion-SG" {
  name        = "grupo_Bastion"
  description = "SSH"
  tags = {
    Name = "grupo_Bastion"
  }
}

resource "aws_vpc_security_group_ingress_rule" "Bastion_allow_ssh_ipv4" {
  security_group_id = aws_security_group.Bastion-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.Bastion-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

/* INSTANCIA FRONT */

resource "aws_instance" "Frontend" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.web_server_instance_type
  vpc_security_group_ids = [aws_security_group.Frontend-SG.id]
  key_name               = var.key_name
  tags = {
    Name = var.frontend_name
  }
  user_data                   = templatefile("scripts/apacheProxy.tftpl", {APIrecord = aws_route53_record.API_record.name, imagesrecord = aws_route53_record.images_record.name})
  user_data_replace_on_change = true

}

/* GRUPO SEGURIDAD FRONT*/
resource "aws_security_group" "Frontend-SG" {
  name        = "grupo_Frontend"
  description = "reglas_front"
  tags = {
    Name = "grupo_Front"
  }
}

resource "aws_vpc_security_group_ingress_rule" "entrada_ssh_bastion_front" {
  security_group_id            = aws_security_group.Frontend-SG.id
  referenced_security_group_id = aws_security_group.Bastion-SG.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "Frontend-SG_allow_http_ipv4" {
  security_group_id = aws_security_group.Frontend-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_Front" {
  security_group_id = aws_security_group.Frontend-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


/* INSTANCIA API */
resource "aws_instance" "API" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.web_server_instance_type
  vpc_security_group_ids = [aws_security_group.API-SG.id]
  key_name               = var.key_name
  tags = {
    Name = var.api_name
  }
  user_data                   = file("scripts/php.sh")
  user_data_replace_on_change = true

}

/* GRUPO SEGURIDAD API */

resource "aws_security_group" "API-SG" {
  name        = "grupo_API"
  description = "reglas_API"
  tags = {
    Name = "grupo_API"
  }
}

resource "aws_vpc_security_group_ingress_rule" "entrada_ssh_bastion_api" {
  security_group_id            = aws_security_group.API-SG.id
  referenced_security_group_id = aws_security_group.Bastion-SG.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_API" {
  security_group_id = aws_security_group.API-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "entrada_http_api_front" {
  security_group_id            = aws_security_group.API-SG.id
  referenced_security_group_id = aws_security_group.Frontend-SG.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

/* INSTANCIA IMAGES */

resource "aws_instance" "Images" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.web_server_instance_type
  vpc_security_group_ids = [aws_security_group.Images-SG.id]
  key_name               = var.key_name
  tags = {
    Name = var.images_name
  }
  user_data                   = file("scripts/images.sh")
  user_data_replace_on_change = true

}

/* GRUPO SEGURIDAD Images */

resource "aws_security_group" "Images-SG" {
  name        = "grupo_Images"
  description = "reglas_images"
  tags = {
    Name = "grupo_Images"
  }
}

resource "aws_vpc_security_group_ingress_rule" "entrada_ssh_bastion_images" {
  security_group_id            = aws_security_group.Images-SG.id
  referenced_security_group_id = aws_security_group.Bastion-SG.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_images" {
  security_group_id = aws_security_group.Images-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "entrada_http_images_front" {
  security_group_id            = aws_security_group.Images-SG.id
  referenced_security_group_id = aws_security_group.Frontend-SG.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}


/* ROUTE53 */
resource "aws_route53_zone" "mainzone" { 
  name = var.zone_name
  vpc {
    vpc_id     = data.aws_vpc.default.id
    vpc_region = var.region
  }
}

resource "aws_route53_record" "Frontend_record" {
  type    = "A"
  name    = "frontend.${var.zone_name}"
  zone_id = aws_route53_zone.mainzone.zone_id
  ttl     = "300"
  records = [aws_instance.Frontend.private_ip]
}

resource "aws_route53_record" "Bastion_record" {
  type    = "A"
  name    = "bastion.${var.zone_name}"
  zone_id = aws_route53_zone.mainzone.zone_id
  ttl     = "300"
  records = [aws_instance.Bastion.private_ip]
}

resource "aws_route53_record" "images_record" {
  type    = "A"
  name    = "images.${var.zone_name}"
  zone_id = aws_route53_zone.mainzone.zone_id
  ttl     = "300"
  records = [aws_instance.Images.private_ip]
}

resource "aws_route53_record" "API_record" {
  type    = "A"
  name    = "api.${var.zone_name}"
  zone_id = aws_route53_zone.mainzone.zone_id
  ttl     = "300"
  records = [aws_instance.API.private_ip]
}