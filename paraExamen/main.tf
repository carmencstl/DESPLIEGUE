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


/* INSTANCIA FRONT */
resource "aws_instance" "Frontend" {
  ami                    = "ami-0bbdd8c17ed981ef9"
  instance_type          = "t2.small"
  vpc_security_group_ids = [aws_security_group.Frontend_SG.id]
  key_name               = "vockey"
  tags = {
    Name = "Frontend"
  }
  user_data                   = templatefile("scripts/apache_proxy.sh", {backendip = aws_instance.Backend.private_ip})
  user_data_replace_on_change = true

}

/* GRUPO FRONT */
resource "aws_security_group" "Frontend_SG" {
  name        = "grupo_Frontend"
  description = "SSH and HTTP"
  tags = {
    Name = "grupo_Frontend"
  }
}

resource "aws_vpc_security_group_ingress_rule" "Frontend_SG_allow_http_ipv4" {
  security_group_id = aws_security_group.Frontend_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "entrada_ssh_bastion" {
  security_group_id            = aws_security_group.Frontend_SG.id
  referenced_security_group_id = aws_security_group.Bastion_SG.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_Frontend" {
  security_group_id = aws_security_group.Frontend_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}



/* INSTANCIA BACK */
resource "aws_instance" "Backend" {
  ami                    = "ami-0bbdd8c17ed981ef9"
  instance_type          = "t2.small"
  vpc_security_group_ids = [aws_security_group.Backend_SG.id]
  key_name               = "vockey"
  tags = {
    Name = "Backend"
  }
  user_data                   = file("scripts/apache_php.sh")
  user_data_replace_on_change = true
}

/* GRUPO BACK */
resource "aws_security_group" "Backend_SG" {
  name        = "grupo_Backend"
  description = "SSH and HTTP Bastion and Frontend"
  tags = {
    Name = "grupo_Backend"
  }
}

resource "aws_vpc_security_group_ingress_rule" "entrada_ssh_bastion_backend" {
  security_group_id            = aws_security_group.Backend_SG.id
  referenced_security_group_id = aws_security_group.Bastion_SG.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "entrada_http_frontend_backend" {
  security_group_id            = aws_security_group.Backend_SG.id
  referenced_security_group_id = aws_security_group.Frontend_SG.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_Backend" {
  security_group_id = aws_security_group.Backend_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}




/* INSTANCIA BASTION */
resource "aws_instance" "Bastion" {
  ami                    = "ami-0bbdd8c17ed981ef9"
  instance_type          = "t2.small"
  vpc_security_group_ids = [aws_security_group.Bastion_SG.id]
  key_name               = "vockey"
  tags = {
    Name = "Bastion"
  }
  user_data                   = file("scripts/install_apache.sh")
  user_data_replace_on_change = true
}

/* GRUPO BASTION */
resource "aws_security_group" "Bastion_SG" {
  name        = "grupo_Bastion"
  description = "SSH"
  tags = {
    Name = "grupo_Bastion"
  }
}

resource "aws_vpc_security_group_ingress_rule" "Bastion_allow_ssh_ipv4" {
  security_group_id = aws_security_group.Bastion_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.Bastion_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


/* IP ELASTICA FRONT */
resource "aws_eip" "ip_elastica_frontend" {
  instance = aws_instance.Frontend.id
  domain   = "vpc"
}


/* IP ELASTICA BASTION */
resource "aws_eip" "ip_elastica_bastion" {
  instance = aws_instance.Bastion.id
  domain   = "vpc"
}


/* ROUTE 53 */
resource "aws_route53_zone" "mainzone" {
  name = var.zone_name
  vpc{
  vpc_id = data.aws_vpc.default.id
  vpc_region = "us-east-1"
  }
  
}


resource "aws_route53_record" "FrontEnd_record" {
  type    = "A"
  name    = "fe.${var.zone_name}"
  zone_id = aws_route53_zone.mainzone.zone_id
  ttl     = "300"
records = [aws_eip.ip_elastica_frontend.public_ip]
}

resource "aws_route53_record" "BackEnd_record" {
  type    = "A"
  name    = "be.${var.zone_name}"
  zone_id = aws_route53_zone.mainzone.zone_id
  ttl     = "300"
  records = [aws_instance.Backend.private_ip]
}

/* INSTANCIA BBDD */
resource "aws_instance" "Database" {
  ami                    = "ami-0bbdd8c17ed981ef9"
  instance_type          = "t2.small"
  vpc_security_group_ids = [aws_security_group.Database_SG.id]
  key_name               = "vockey"
  tags = {
    Name = "Database"
  }
  user_data                   = file("scripts/install_mysql.sh")
  user_data_replace_on_change = true
}

/* GRUPO BBDD */
resource "aws_security_group" "Database_SG" {
  name        = "grupo_Database"
  description = "MySQL from Backend and SSH from Bastion"
  tags = {
    Name = "grupo_Database"
  }
}

resource "aws_vpc_security_group_ingress_rule" "entrada_ssh_bastion_database" {
  security_group_id            = aws_security_group.Database_SG.id
  referenced_security_group_id = aws_security_group.Bastion_SG.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "entrada_mysql_backend_database" {
  security_group_id            = aws_security_group.Database_SG.id
  referenced_security_group_id = aws_security_group.Backend_SG.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}

resource "aws_vpc_security_group_egress_rule" "allow_all_Database" {
  security_group_id = aws_security_group.Database_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

/* ROUTE 53 BBDD */
resource "aws_route53_record" "Database_record" {
  type    = "A"
  name    = "db.${var.zone_name}"
  zone_id = aws_route53_zone.mainzone.zone_id
  ttl     = "300"
  records = [aws_instance.Database.private_ip]
}

/* CNAME */
resource "aws_route53_record" "www_record" {
  zone_id = aws_route53_zone.mainzone.zone_id
  name    = "www.${var.zone_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_route53_record.FrontEnd_record.fqdn]
}

