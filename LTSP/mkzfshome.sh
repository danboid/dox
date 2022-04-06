#!/bin/bash
if [ "$PAM_USER" != "lightdm" ] && [ ! -d "/home/$PAM_USER" ] ; then
        zfs create -o mountpoint=/home/$PAM_USER astarray/home/$PAM_USER
        chown $PAM_USER:1001 /home/$PAM_USER
        chmod go-rwx /home/$PAM_USER
        zfs set refquota=30G astarray/home/$PAM_USER
fi
