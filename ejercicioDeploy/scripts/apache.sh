#!/bin/bash -xe
exec > /tmp/userdata.log 2>&1   

apt update -y                   
apt upgrade -y                  
apt install -y apache2         

a2dismod autoindex
a2dismod status
a2dismod userdir
a2dismod info
           
systemctl restart apache2

apt install -y ruby-full wget

cd /home/ubuntu
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
./install auto

systemctl start codedeploy-agent
systemctl enable codedeploy-agent