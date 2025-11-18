#!/bin/bash -xe
exec > /tmp/userdata.log 2>&1   # Redirige toda la salida (stdout y stderr) a un log para depuración

apt update -y                   # Actualiza la lista de paquetes disponibles
apt upgrade -y                  # Actualiza los paquetes instalados a su última versión
apt install -y php8.1           # Instala PHP 8.1
apt install -y apache2          # Instala el servidor web Apache

# Crea un nuevo archivo de configuración para un sitio en Apache
cat > /etc/apache2/sites-available/php.conf << EOF
<VirtualHost *:80>
    DocumentRoot /var/www/php
    # Si no encuentra la url cogerá el que esté activo,
    # si hay varios el primero alfabéticamente
    
    # ServerName dhr-server.com
    # Esto sería la url de nuestro servidor DNS

</VirtualHost>
EOF

mkdir -p /var/www/php           # Crea el directorio raíz del sitio PHP

# Crea una página PHP básica que muestra información del servidor
cat > /var/www/php/index.php << EOF
<?php
    // Muestra toda la información de configuración de PHP
    phpinfo();
?>
EOF

a2dissite 000-default           # Desactiva el sitio por defecto de Apache
a2ensite php.conf               # Activa el nuevo sitio PHP
systemctl restart apache2       # Reinicia Apache para aplicar los cambios
