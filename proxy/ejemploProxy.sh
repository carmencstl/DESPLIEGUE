
cat > /etc/apache2/sites-available/php.conf << EOF
<VirtualHost *:80>
    DocumentRoot /var/www/...

    ServerName 
    ProxyPass "/" "http://fe.carmencastillogaitan.com/"
    ProxyPassReverse "/" "http://fe.carmencastillogaitan.com/"
    
</VirtualHost>
EOF
