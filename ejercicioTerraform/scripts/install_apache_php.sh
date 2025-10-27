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
cat > /var/www/php/index.php << EOF
    <?php
        //Show all information, defaults to INFO_ALL
        phpinfo();
        ?>
EOF

a2dissite 000-default
a2ensite php.conf
systemctl restart apache2