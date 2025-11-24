#!/bin/bash -xe
exec > /tmp/userdata.log 2>&1

# Actualiza paquetes
apt update -y
apt install -y apache2 php8.1 php-mysql mysql-server

# Configurar Apache con PHP
cat > /etc/apache2/sites-available/php.conf << EOF
<VirtualHost *:80>
    DocumentRoot /var/www/php
</VirtualHost>
EOF

mkdir -p /var/www/php
cat > /var/www/php/index.php << EOF
<?php
phpinfo();
?>
EOF

a2dissite 000-default
a2ensite php.conf
systemctl restart apache2
systemctl enable apache2

# Configurar MySQL
sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i "s/^mysqlx-bind-address.*/mysqlx-bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

systemctl restart mysql
systemctl enable mysql

# Crear usuario y base de datos
mysql -e "CREATE USER IF NOT EXISTS 'dbuser'@'localhost' IDENTIFIED BY 'Password1!';"

#mysql -u dbuser -p
#Password1!
#exit;
