#!/bin/bash
#
# MrVein.sh - a wrapper for lookup.pl to fetch multiple student email addresses from LDAP
# You must input a Linux text file with one username per line
# It will output a csv file suitable for use with vermin.sh ie in the format username,email@ddress

# Check for input file
if [ -z $1 ]; then
	echo "You must provide a text file as the first argument with one username per line"
	exit 1
fi

# Convert the input file into a UNIX text file, in case it is a DOS/Windows text file
tr -d '\r' < $1 > $1.unix

# Translate all uppercase characters to lowercase
tr '[:upper:]' '[:lower:]' < $1.unix > $1.lower

# Main loop
for v in $(cat $1.lower); do
	MAIL=$(lookup uid $v | grep -a '\[mail\]' | cut -c 8- | sed 's/]//')
	if [ -z $MAIL ]; then
	    echo "$v not found"
	    else
	        echo "$v,$MAIL" | tee -a $1.csv
	fi
done

rm $1.unix $1.lower

