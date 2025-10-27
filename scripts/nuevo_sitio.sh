#!/bin/bash

cat > /etc/apache2/sites-available/nuevo.conf << EOF
    <VirtualHost *:80>
    DocumentRoot /var/www/nuevo
    ServerName: webcarmen.duckdns.org
    </VirtualHost>
EOF

a2ensite nuevo
a2dissite 000-default

mkdir -p /var/www/nuevo

cat > /var/www/nuevo/index.html << EOF
    <HTML>
    <BODY>
    <H1>NUEVO SERVER</H1>
    </BODY>
    </HTML>
    EOF
    systemct1 restart apache2.service