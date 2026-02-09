#!/bin/bash

apt update
apt upgrade -y
apt install apache2 -y

cat > /etc/apache2/sites-available/images.conf << EOF
<VirtualHost *:80>
    DocumentRoot /var/www/images
</VirtualHost>
EOF

mkdir -p /var/www/images     

cat > /var/www/images/index.html << EOF
    <html>
        <body>
        <h1>SERVIDOR IMAGES CARMEN CASTILLO GAITAN</h1>
        </body>
    </html>
EOF

a2dissite 000-default   
a2ensite images.conf
systemctl restart apache2