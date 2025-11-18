#!/bin/bash -xe
exec > /tmp/userdata.log 2>&1

apt update -y
apt upgrade -y
apt install mysql-server -y

#sudo mysql -u root
#create user 'dbuser'@'%' IDENTIFIED BY 'password1';
#exit

#cd /etc/mysql
#cd mysql.conf.d
#vi mysqld.conf
#bind-address = 0.0.0.0 y el de abajo a 0.0.0.0 igual
#sudo systemctl restart mysql.service
#sudo mysql -u root -e "SELECT User, Host FROM mysql.user WHERE User='dbuser';"