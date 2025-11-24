#!/bin/bash -xe
exec > /tmp/userdata.log 2>&1   


apt update -y                   
apt upgrade -y                  
apt install -y apache2          

systemctl restart apache2       