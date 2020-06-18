#!/bin/bash

username=$1

umount /home/$username/bin
umount /home/$username/dev
umount /home/$username/lib
umount /home/$username/lib64
umount /home/$username/usr/bin
umount /home/$username/usr/lib


