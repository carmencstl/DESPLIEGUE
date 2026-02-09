#!/bin/bash

hostnamectl set-hostname BACKEND

exec > /tmp/userdata.log 2>&1


apt update -y
apt upgrade -y


apt install apache2 -y
apt install php -y
apt install libapache2-mod-php -y

apt install mysql-client -y
apt install php-mysql -y


cat>/etc/apache2/sites-available/misitio.conf<<EOF
<VirtualHost *:80>
DocumentRoot /var/www/misitio
</VirtualHost>
EOF

mkdir -p /var/www/misitio

cat>/var/www/misitio/index.php<<'EOF' #para que no expanda las variables ed php y las mantega
<?php $saludo="Hola"?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <h2><?php echo $saludo?></h2>
    <h1>estas en el backend de Miriam Diaz Plaza funcionando con php</h1>
</body>
</html>
EOF

a2dissite 000-default
a2ensite misitio.conf
systemctl restart apache2

