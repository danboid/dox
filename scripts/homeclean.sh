#!/bin/bash

# Home directory clean-up script

# This script should be run as root from within /home

# Change the -mtime value to set the cut off point in days
# eg -600 will delete all directories that havent been
# modified within the last 600 days.

find * -maxdepth 0 -type d |
    while read DIR
    do
        LINES=$(find "$DIR" -maxdepth 3 -type f -mtime -600 -print -quit)
        test -z "$LINES" && echo "Deleting $DIR" && rm -rf "$DIR"
    done

