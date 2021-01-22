#!/bin/bash
# zfsquota.sh
# To create the input file:
# ls -d -1 /home/* | cut -c 7- > homedirs.txt

# Check script is being run as root
if [ $EUID -ne 0 ]; then
	echo "This script must be run with sudo or as root"
	exit 1
fi

# Check for input file
if [ -z $1 ]; then
	echo -e "You must provide a text file as the first argument with one username per line\n"
	exit 1
fi

# Main loop
for u in $(cat $1); do
	zfs set refquota=300M zhome/home/$u
	if [ "$?" == 0 ]; then
		echo "Increased refquota size for $u" 
	else
		echo "Failed to increase refquota for $u"
	fi
done
