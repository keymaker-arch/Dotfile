#!/bin/bash

# get this from the shared file's attribute
SHARE_LOC=//192.168.122.122/share
MOUNT_LOC=/home/han/mnt/win10_share
USER_NAME=han
PASSWORD=123456

sudo mount -t cifs $SHARE_LOC $MOUNT_LOC -o username=$USER_NAME,password=$PASSWORD,dir_mode=0777,file_mode=0777
