#!/bin/bash -xe
exec > /tmp/userdata.log 2>&1   # Redirige toda la salida (stdout y stderr) a un log para depuración

apt update -y                   # Actualiza la lista de paquetes disponibles
apt upgrade -y                  # Actualiza los paquetes instalados a su última versión
apt install -y php8.1           # Instala PHP 8.1
apt install -y apache2          # Instala el servidor web Apache

cat > /etc/apache2/sites-available/php.conf << EOF
<VirtualHost *:80>
    DocumentRoot /var/www/php
</VirtualHost>
EOF

mkdir -p /var/www/php           # Crea el directorio raíz del sitio PHP


cat > /var/www/php/index.php << EOF
<?php
    // Muestra toda la información de configuración de PHP
    echo "EN BACKEND SERVER WITH PHP INSTALLED\n";
    phpinfo();
?>
EOF

a2dissite 000-default           # Desactiva el sitio por defecto de Apache
a2ensite php.conf               # Activa el nuevo sitio PHP
systemctl restart apache2       # Reinicia Apache para aplicar los cambios
