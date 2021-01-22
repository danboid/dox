#!/bin/bash
# vermin - batch virtualmin account creation script by Dan MacDonald
#
# This script depends upon pwgen and 'mail' from mailutils. 
# postfix must be installed and configured to send email.
# virtualmin depends upon postfix so using another MTA isn't optional if running on the same box.

# Check script is being run as root
if [ $EUID -ne 0 ]; then
	echo "This script must be run with sudo or as root"
	exit 1
fi

# Check for csv input file
if [ -z $1 ]; then
	echo "You must provide a csv file as the first argument, formatted as username,email with one user per line"
	exit 1
fi

# Convert the input file into a UNIX text file, in case it is a DOS/Windows text file
tr -d '\r' < $1 > $1.unix

# Main loop
for v in $(cat $1.unix); do
	USER=$(echo "$v" | cut -d ',' -f 1)
	MAIL=$(echo "$v" | cut -d ',' -f 2)
	PWRD=$(pwgen 12 1)
	virtualmin create-domain --domain $USER.unicornfoundation.org --user $USER --pass $PWRD --email $MAIL --template students --plan student --limits-from-plan --features-from-plan
	if [ "$?" == 0 ]; then
		echo "`date` Account successfully created for $USER" | tee -a /var/log/vermin.log
		echo -e "Hi $USER,\n\nYour account has been created and can be accessed at: \n\nYour username is $USER and your password is $PWRD\n\nOnly use lower-case when entering your user name." | mail -s "UF domain account created" $MAIL
	else
		echo "`date` Failed to create account for $USER" | tee -a /var/log/vermin.log
	fi
done

rm $1.unix

