#!/bin/bash



x=$(pgrep install_letsencrypt.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi


export DISPLAY=:0.0
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin
HOME=/root

source $HOME/.profile

Password=`/usr/webcp/get_password.sh`

AdminEmail=$(mysql cpadmin -u root -p${Password} -se "SELECT email_address FROM admin WHERE deleted = 0 LIMIT 1;")

if [ "$AdminEmail" == "" ]
then
	exit
fi


apt-get update

apt-get install expect -y

if [ ! -d "/etc/nginx/ssl" ]
then
	mkdir /etc/nginx/ssl
fi

rm -fr /opt/eff.org

cd /etc/nginx/ssl
rm -fr /etc/nginx/ssl/letsencrypt

git clone https://github.com/letsencrypt/letsencrypt

cd /etc/nginx/ssl/letsencrypt
./letsencrypt-auto

rm -fr /var/www/html/webcp/nm/letsencrypt.install
