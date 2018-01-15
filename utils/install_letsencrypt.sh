#!/bin/bash

x=$(pgrep install_letsencrypt.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

export DISPLAY=:0.0
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin
HOME=/root

source $HOME/.bash_profile

yum install epel-release -y

cd /tmp
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
rpm -Uvh epel-release-6*.rpm

yum install expect -y

if [ ! -d "/etc/httpd/conf/ssl" ]
then
	mkdir /etc/httpd/conf/ssl
fi

cd /etc/httpd/conf/ssl
rm -fr /etc/httpd/conf/ssl/letsencrypt

git clone https://github.com/letsencrypt/letsencrypt

cd /etc/httpd/conf/ssl/letsencrypt
./letsencrypt-auto

rm -fr /var/www/html/webcp/nm/letsencrypt.install
sleep 1
