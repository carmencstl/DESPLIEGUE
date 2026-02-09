#!/bin/bash -xe
exec > /tmp/userdata.log 2>&1   

apt update -y                   
apt upgrade -y                  
apt install -y apache2         

a2dismod autoindex -f
a2dismod status
a2dismod userdir
a2dismod info
           
systemctl restart apache2      