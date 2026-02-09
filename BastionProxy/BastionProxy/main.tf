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

/*--------------------------------BASTION--------------------------------*/
resource "aws_instance" "BastionPractica" {
    ami=data.aws_ami.ubuntu.id
    key_name = var.key_name
    instance_type = var.instance_type
    tags = {
        Name="BastionPractica"
    }

    user_data = file("scripts/bastion.sh")
    user_data_replace_on_change = true
    vpc_security_group_ids = [aws_security_group.GS_Bastion.id, aws_security_group.FROM_Bastion.id]
}

resource "aws_security_group" "GS_Bastion" {
  name="GS_Bastion"
  description = "Grupo de seguridad para administrar las reglas de entrada y salida del bastion"
}

resource "aws_security_group" "FROM_Bastion" {
  name="FROM_Bastion"
  description = "Grupo de seguridad para identificar al bastion"
}

//permite la entrada por ssh al bastion desde cualquier lugar
resource "aws_vpc_security_group_ingress_rule" "ssh_bastion" {
  cidr_ipv4 = var.any_ip
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
  security_group_id = aws_security_group.GS_Bastion.id
}
resource "aws_vpc_security_group_egress_rule" "all_bastion" {
  cidr_ipv4 = var.any_ip
  ip_protocol = "-1"
  security_group_id = aws_security_group.GS_Bastion.id
}

//ip elastica del bastion
resource "aws_eip" "ipElasticaBastion" {
  instance=aws_instance.BastionPractica.id
  domain="vpc"
}

/*--------------------------------FRONT DNS+PROXY--------------------------------*/
resource "aws_instance" "FrontProxy" {
    ami=data.aws_ami.ubuntu.id
    key_name = var.key_name
    instance_type = var.instance_type
    tags = {
        Name="FrontProxy"
    }

    # vpc_security_group_ids = [aws_security_group.GS_Front_Proxy.id]
    vpc_security_group_ids = [aws_security_group.GS_Front_Proxy.id, aws_security_group.FROM_Front.id]
    
    //user_data = file("scripts/front.sh")backend_ip=aws_instance.BackPractica.private_ip
    user_data=templatefile("scripts/front.tftpl",{backend_ip=aws_instance.BackPractica.private_ip,front_dns="frontend.${var.zone_name}"})
    user_data_replace_on_change = true
}

resource "aws_security_group" "GS_Front_Proxy" {
  description = "Grupo de seguridad para administrar las reglas de entrada y salida del servidor de front"
}

resource "aws_security_group" "FROM_Front" {
  description = "Grupo de seguridad para identificar al front"
  
}

# //Permite la entrada por ssh desde el bastion
resource "aws_vpc_security_group_ingress_rule" "ssh_front" {
  referenced_security_group_id = aws_security_group.FROM_Bastion.id
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
  security_group_id = aws_security_group.GS_Front_Proxy.id
}

# //permite trafico desde cualquier ip al front
resource "aws_vpc_security_group_ingress_rule" "http_front" {
  cidr_ipv4 = var.any_ip
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
  security_group_id = aws_security_group.GS_Front_Proxy.id
}

# //permite el trafico de salida a cualquier ip
resource "aws_vpc_security_group_egress_rule" "all_front" {
  cidr_ipv4 = var.any_ip
  ip_protocol = "-1"
  security_group_id = aws_security_group.GS_Front_Proxy.id
}

//IP elastica del front
resource "aws_eip" "ipElasticaFront" {
  instance=aws_instance.FrontProxy.id
  domain="vpc"
}


# /*--------------------------------BACK--------------------------------*/
resource "aws_instance" "BackPractica" {
    ami=data.aws_ami.ubuntu.id
    key_name = var.key_name
    instance_type = var.instance_type
    tags = {
        Name="BackPractica"
    }

    vpc_security_group_ids = [aws_security_group.GS_Back.id, aws_security_group.FROM_Back.id]
    
    user_data = file("scripts/back.sh")
    user_data_replace_on_change = true
}

resource "aws_security_group" "GS_Back" {
  description = "Grupo de seguridad para administrar las reglas de entrada y salida del servidor de front"
}

resource "aws_security_group" "FROM_Back" {
  description = "Grupo de seguridad para identificar al back"
  
}

//Permite la entrada por ssh desde el bastion
resource "aws_vpc_security_group_ingress_rule" "ssh_back" {
  referenced_security_group_id = aws_security_group.FROM_Bastion.id
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
  security_group_id = aws_security_group.GS_Back.id
}

//permite trafico desde el front
resource "aws_vpc_security_group_ingress_rule" "http_back" {
  referenced_security_group_id = aws_security_group.FROM_Front.id
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
  security_group_id = aws_security_group.GS_Back.id
}

//permite el trafico de salida a cualquier ip
resource "aws_vpc_security_group_egress_rule" "all_back" {
  cidr_ipv4 = var.any_ip
  ip_protocol = "-1"
  security_group_id = aws_security_group.GS_Back.id
}

# /*--------------------------------BASE DATOS--------------------------------*/
resource "aws_instance" "BaseDatos" {
    ami=data.aws_ami.ubuntu.id
    key_name = var.key_name
    instance_type = var.instance_type
    tags = {
        Name="BaseDatos"
    }

    vpc_security_group_ids = [aws_security_group.GS_BASE_DATOS.id]
    
    user_data = file("scripts/basedatos.sh")
    //user_data=templatefile("scripts/front.sh",{backend_ip=aws.instance.BackPractica.pri})
    user_data_replace_on_change = true
}

resource "aws_security_group" "GS_BASE_DATOS" {
  description = "Grupo de seguridad para administrar las reglas de entrada y salida del servidor de base de datos"
}

# //Permite la entrada por ssh desde el bastion
resource "aws_vpc_security_group_ingress_rule" "ssh_bd" {
  referenced_security_group_id = aws_security_group.FROM_Bastion.id
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
  security_group_id = aws_security_group.GS_BASE_DATOS.id
}

# //permite trafico desde el back
resource "aws_vpc_security_group_ingress_rule" "bd" {
  referenced_security_group_id = aws_security_group.FROM_Back.id
  from_port = 3306
  to_port = 3306
  ip_protocol = "tcp"
  security_group_id = aws_security_group.GS_BASE_DATOS.id
}

# //permite el trafico de salida a cualquier ip
resource "aws_vpc_security_group_egress_rule" "all_bd" {
  cidr_ipv4 = var.any_ip
  ip_protocol = "-1"
  security_group_id = aws_security_group.GS_BASE_DATOS.id
}


# /*--------------------------------ZONA DNS--------------------------------*/
resource "aws_route53_zone" "zona_primaria" {
  name=var.zone_name
  vpc{
    vpc_id=data.aws_vpc.defaultNetwork.id
    vpc_region=var.region
  }
}

resource "aws_route53_record" "front_practica" {
  zone_id = aws_route53_zone.zona_primaria.id
  name="frontend"
  type = "A" //de ipv4 unica url contra unica ip
  ttl=300
  records = [aws_instance.FrontProxy.private_ip] /*ip del servidor Puede ser privada o publica ya que la resolucion es solo dentro de la vpc*/
}

//este apunta a www.practicacompleta.org que a su vez redirecciona a frontend.practicacompleta.org
resource "aws_route53_record" "front_practica_alias" {
  zone_id = aws_route53_zone.zona_primaria.id
  name="www" //alias del dominio
  type = "CNAME"
  ttl=300
  records = [aws_route53_record.front_practica.fqdn] //son otra url solo muestra la var_zone si queremos que llegue a www.frontend hay que añadirlo en el name
}

//Apex del front para que tambien este servidor mapee la raiz
# resource "aws_route53_record" "apex_practica" {
#   zone_id = aws_route53_zone.zona_primaria.zone_id
#   name    = ""        # <-- ESTO CREARÁ EL APEX
#   type    = "A"
#   ttl     = 300
#   records = [aws_instance.FrontProxy.private_ip]
# }


# //dns del bastion?
# //¿Habria que hacer un record para el back con el dns +/api?