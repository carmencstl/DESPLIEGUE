hostnamectl set-hostname BASTION

exec > /tmp/userdata.log 2>&1


apt update
apt upgrade -y

