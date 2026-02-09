#!/bin/bash
hostnamectl set-hostname BASEDATOS

exec > /tmp/userdata.log 2>&1 #fichero temporal donde guarda todo lo de la instalacion

apt update
apt upgrade -y

#INSTALAR MYSQL
apt install mysql-server -y

# systemctl restart mysql
# #para que arranque automaticamente
# systemctl enable mysql

#creamos un usuario
mysql -e "CREATE USER 'dbuser'@'%' IDENTIFIED BY 'password1';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'dbuser'@'%' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

#modificamos la siguiente linea para que la cambiamos a 0.0.0.0 para que escuche desde cualqueir lugar. Si solo queremos que escuche desde el servidor habra que especificarlo en el grupo de seguridad
sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i "s/^mysqlx-bind-address.*/mysqlx-bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

# Reiniciar MySQL
systemctl restart mysql
#para que arranque automaticamente
systemctl enable mysql
