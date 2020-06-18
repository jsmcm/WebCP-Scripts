#!/bin/bash

username=$1
usernumber=$2

mkdir /home/$username/bin
mkdir /home/$username/dev
mkdir /home/$username/etc
mkdir /home/$username/lib
mkdir /home/$username/lib64
mkdir /home/$username/usr/bin -p
mkdir /home/$username/usr/lib -p


mount --bind /bin /home/$username/bin
mount --bind /dev /home/$username/dev
mount --bind /lib /home/$username/lib
mount --bind /lib64 /home/$username/lib64
mount --bind /usr/bin /home/$username/usr/bin
mount --bind /usr/lib /home/$username/usr/lib


mount -o remount,ro,bind /home/$username/bin
mount -o remount,ro,bind /home/$username/dev
mount -o remount,ro,bind /home/$username/lib
mount -o remount,ro,bind /home/$username/lib64
mount -o remount,ro,bind /home/$username/usr/lib
mount -o remount,ro,bind /home/$username/usr/bin

echo "root:x:0:0:root:/root:/bin/bash" > /home/$username/etc/passwd
echo "$username:x:$usernumber:$usernumber:,,,:/home/$username:/bin/bash" >> /home/$username/etc/passwd

echo "root:x:0:" > /home/$username/etc/group
echo "$username:x:$usernumber:" >> /home/$username/etc/group

chown root.root /home/$username/

