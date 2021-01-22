#!/bin/bash
# vminarc - archive then remove multiple virtualmin accounts
#

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

# Convert the input file into a UNIX text file, in case it is a DOS/Windows text file
tr -d '\r' < $1 > $1.unix

# Translate all uppercase characters to lowercase
tr '[:upper:]' '[:lower:]' < $1.unix > $1.lower

# Main loop
for v in $(cat $1.lower); do

      virtualmin backup-domain --all-features --all-virtualmin --ignore-errors --user $v --dest /zhome/arc/$v.tgz
	if [ "$?" == 0 ]; then
		echo "`date` Account successfully backed up for $v" 
	else
		echo "`date` Failed to backup account for $v" 
	fi
	
	virtualmin delete-domain --domain $v.unicornfoundation.org --user $v
	if [ "$?" == 0 ]; then
		echo "`date` Account successfully deleted for $v" 
	else
		echo "`date` Failed to delete account for $v" 
	fi
done

rm $1.unix $1.lower
