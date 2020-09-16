#!/bin/bash

username=$1
usernumber=$2


mkdir /home/$username/bin
#mkdir /home/$username/sbin
mkdir /home/$username/dev
mkdir /home/$username/etc/alternatives -p
mkdir /home/$username/etc/php -p
mkdir /home/$username/etc/ssl -p
mkdir /home/$username/lib
mkdir /home/$username/lib64
mkdir /home/$username/usr/bin -p
mkdir /home/$username/usr/lib -p
mkdir /home/$username/usr/share -p
mkdir /home/$username/var -p
mkdir /home/$username/run -p



if [ -d "/home/$username/public_html" ]
then
	mv -f /home/$username/public_html /home/$username/home/$username
	mv -f /home/$username/.cron /home/$username/home/$username
	mv -f /home/$username/.editor /home/$username/home/$username
	mv -f /home/$username/.passwd /home/$username/home/$username
fi

chown $username.$username /home/$username/home/$username -R


mount --bind /bin /home/$username/bin
#mount --bind /sbin /home/$username/sbin
mount --bind /etc/alternatives /home/$username/etc/alternatives
mount --bind /etc/php /home/$username/etc/php
mount --bind /etc/ssl /home/$username/etc/ssl
mount --bind /dev /home/$username/dev
mount --bind /lib /home/$username/lib
mount --bind /lib64 /home/$username/lib64
mount --bind /usr/bin /home/$username/usr/bin
mount --bind /usr/lib /home/$username/usr/lib
mount --bind /usr/share /home/$username/usr/share
mount --bind /var /home/$username/var
mount --bind /run /home/$username/run


mount -o remount,ro,bind /home/$username/bin
#mount -o remount,ro,bind /home/$username/sbin
mount -o remount,ro,bind /home/$username/etc/alternatives
mount -o remount,ro,bind /home/$username/etc/php
mount -o remount,ro,bind /home/$username/etc/ssl
mount -o remount,ro,bind /home/$username/dev
mount -o remount,ro,bind /home/$username/lib
mount -o remount,ro,bind /home/$username/lib64
mount -o remount,ro,bind /home/$username/usr/lib
mount -o remount,ro,bind /home/$username/usr/bin
mount -o remount,ro,bind /home/$username/usr/share
mount -o remount,ro,bind /home/$username/var
mount -o remount,ro,bind /home/$username/run


echo "nameserver 8.8.8.8" > /home/$username/etc/resolv.conf

echo "root:x:0:0:root:/root:/bin/bash" > /home/$username/etc/passwd
echo "$username:x:$usernumber:$usernumber:,,,:/home/$username:/bin/bash" >> /home/$username/etc/passwd

echo "root:x:0:" > /home/$username/etc/group
echo "$username:x:$usernumber:" >> /home/$username/etc/group

chown root.root /home/$username/

