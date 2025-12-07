#!/bin/bash -xe
exec > /tmp/userdata.log 2>&1  


apt update -y                  
apt upgrade -y                 
apt install -y php8.1           
apt install -y apache2         

cat > /etc/apache2/sites-available/php.conf << EOF
<VirtualHost *:80>
    DocumentRoot /var/www/php
</VirtualHost>
EOF

mkdir -p /var/www/php       

cat > /var/www/php/index.html << EOF
<HTML>
    <H1>Carmen Castillo Gaitan</H1>
</HTML>
EOF

a2dismod autoindex
a2dissite 000-default          
a2ensite php.conf           
systemctl restart apache2       