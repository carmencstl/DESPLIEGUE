#!/bin/bash


apt update
apt upgrade -y
apt install apache2 -y

cat > /etc/apache2/sites-available/nuevositio.conf << EOF
<VirtualHost *:80>
    DocumentRoot /var/www/nuevo
    ServerName 
    </VirtualHost>
EOF

mkdir /var/www/nuevo.conf