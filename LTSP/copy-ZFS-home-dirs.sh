#!/bin/bash

# Script to transfer all users home dirs from one machine into individual ZFS datasets on the target

# Before running this script, ensure that the ssh user you use to run this script is allowed to run rsync
# with sudo but without having to enter a password. This can be achieved by adding a line like this
# to the end of your sudoers file on the remote (source) machine, uncommented:

# dan ALL=NOPASSWD:/usr/bin/rsync

# Check script is being run as root
if [ $EUID -ne 0 ]; then
	echo "This script must be run with sudo or as root"
	exit 1
fi

# IP address of source machine to copy home dirs from
sourceIP=ABC.DEF.GH.I

# ssh user, must have sudo rights
user=youruser

# Target pool
pool=astarray

for name in $(ssh $user@$sourceIP "ls -1 /home"); do
    if [ ! -d "/home/$name" ]; then
        echo Creating dataset for $name
        zfs create -o mountpoint=/home/$name $pool/home/$name
    fi
    echo Syncing files for user $name
    rsync -aAruX --rsync-path="sudo rsync" $user@$sourceIP:/home/$name /home/
done
