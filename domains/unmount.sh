#!/bin/bash

username=$1

pkill -u $username
pkill -u $username

umount -l /home/$username/etc/alternatives
umount -l /home/$username/bin
umount -l /home/$username/dev
umount -l /home/$username/lib
umount -l /home/$username/lib64
umount -l /home/$username/usr/bin
umount -l /home/$username/usr/lib
umount -l /home/$username/usr/share



