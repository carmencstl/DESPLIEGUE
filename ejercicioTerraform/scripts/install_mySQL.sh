#!/bin/bash -xe
exec > /tmp/userdata.log 2>&1

<<<<<<< HEAD

=======
>>>>>>> f45f777d761c994eb69b924631e33c5782b4c1fd
apt update -y
apt upgrade -y
apt install mysql-server -y

<<<<<<< HEAD

sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i "s/^mysqlx-bind-address.*/mysqlx-bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

systemctl restart mysql
systemctl enable mysql

mysql -e "create user 'dbuser'@'%' IDENTIFIED BY 'password1';"


=======
>>>>>>> f45f777d761c994eb69b924631e33c5782b4c1fd
#sudo mysql -u root
#create user 'dbuser'@'%' IDENTIFIED BY 'password1';
#exit

#cd /etc/mysql
#cd mysql.conf.d
#vi mysqld.conf
#bind-address = 0.0.0.0 y el de abajo a 0.0.0.0 igual
#sudo systemctl restart mysql.service
<<<<<<< HEAD
#sudo mysql -u root -e "SELECT User, Host FROM mysql.user WHERE User='dbuser';"
=======
#sudo mysql -u root -e "SELECT User, Host FROM mysql.user WHERE User='dbuser';"
>>>>>>> f45f777d761c994eb69b924631e33c5782b4c1fd
