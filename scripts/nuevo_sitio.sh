#!/bin/bash

cat > /etc/apache2/sites-available/nuevo.conf << EOF
    <VirtualHost *:88>
    DocumentRoot /var/www/nuevo
    ServerName: 
    </VirtualHost>
EOF
mkdir /var/www/nuevo