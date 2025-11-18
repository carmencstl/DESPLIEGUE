terraform {
  backend "s3" {
    key    = "ejer1.tfstate"      # Nombre del archivo de estado remoto
    bucket = "web-carmen"         # Bucket S3 donde se almacena el estado
    region = "us-east-1"          # Región del bucket
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"   # Proveedor AWS oficial
      version = "~> 6.0"          # Versión compatible del proveedor
    }
  }

  required_version = ">= 1.2"     # Versión mínima de Terraform requerida
}

provider "aws" {
  region = "us-east-1"            # Región donde se desplegarán los recursos
}

# --------------------------
# INSTANCIA FRONTEND (Apache + PHP)
# --------------------------
resource "aws_instance" "FrontEnd" {  # Recurso EC2 llamado "FrontEnd"
  ami                     = "ami-0bbdd8c17ed981ef9"   # Imagen del sistema operativo (Ubuntu)
  instance_type           = "t2.small"                # Tipo/tamaño de la instancia
  vpc_security_group_ids  = [aws_security_group.FrontEnd.id]  # Asocia el grupo de seguridad del frontend
  key_name                = "vockey"                  # Clave SSH para acceder a la instancia
  tags = {
    Name = "instancia_frontend"                       # Etiqueta de identificación
  }
  user_data                    = file("scripts/install_apache_php.sh")  # Script de configuración (userdata)
  user_data_replace_on_change  = true                 # Reemplaza userdata si el archivo cambia
}

# --------------------------
# INSTANCIA BASE DE DATOS (MySQL)
# --------------------------
resource "aws_instance" "BBDD" {                      # Recurso EC2 llamado "BBDD"
  ami                     = "ami-0bbdd8c17ed981ef9"   # Misma imagen base (Ubuntu)
  instance_type           = "t2.small"                # Tipo/tamaño de la instancia
  vpc_security_group_ids  = [aws_security_group.BBDD.id]  # Asocia grupo de seguridad BBDD
  key_name                = "vockey"                  # Clave SSH para acceso
  tags = {
    Name = "instancia_bbdd"                           # Etiqueta de identificación
  }
  user_data                    = file("scripts/install_mySQL.sh")  # Script de instalación de MySQL
  user_data_replace_on_change  = true                 # Reemplaza userdata si cambia el script
}

# --------------------------
# GRUPO DE SEGURIDAD FRONTEND
# --------------------------
resource "aws_security_group" "FrontEnd" {
  name        = "grupo_Front"                         # Nombre del SG
  description = "Permitir HTTP y SSH"                 # Descripción del SG

  tags = {
    Name = "grupo_Front"
  }
}

resource "aws_vpc_security_group_ingress_rule" "front_allow_ssh_ipv4" {
  security_group_id = aws_security_group.FrontEnd.id  # Asocia al SG FrontEnd
  cidr_ipv4         = "0.0.0.0/0"                     # Permite acceso desde cualquier IP
  from_port         = 22                              # Puerto SSH
  ip_protocol       = "tcp"                           # Protocolo TCP
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "front_allow_http_ipv4" {
  security_group_id = aws_security_group.FrontEnd.id  # Asocia al SG FrontEnd
  cidr_ipv4         = "0.0.0.0/0"                     # Acceso abierto desde internet
  from_port         = 80                              # Puerto HTTP
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.FrontEnd.id  # Permite salida desde el FrontEnd
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"                            # Todos los protocolos
}

# --------------------------
# GRUPO DE SEGURIDAD BASE DE DATOS
# --------------------------
resource "aws_security_group" "BBDD" {
  name        = "grupo_BBDD"                          # Nombre del SG
  description = "Para BBDD"                           # Descripción del SG

  tags = {
    Name = "grupo_BBDD"
  }
}

resource "aws_vpc_security_group_ingress_rule" "bbdd_allow_ssh_ipv4" {
  security_group_id = aws_security_group.BBDD.id      # SG de la base de datos
  cidr_ipv4         = "0.0.0.0/0"                     # Permite SSH desde cualquier IP
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "front_bbdd_entrada" {
  security_group_id             = aws_security_group.BBDD.id          # SG de la BBDD
  referenced_security_group_id  = aws_security_group.FrontEnd.id      # Permite tráfico solo desde el frontend
  from_port                     = 3306                                # Puerto MySQL
  ip_protocol                   = "tcp"
  to_port                       = 3306
}

resource "aws_vpc_security_group_egress_rule" "bbdd_allow_all" {
  security_group_id = aws_security_group.BBDD.id       # Permite salida desde la BBDD
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"                             # Todos los protocolos
}
