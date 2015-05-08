#!/bin/sh
#
# Checks public IP via ident.me and triggers python script to email Raspberry Pi's IPs
#

IPFILE=~/ipaddress
CURRENT_IP=$(wget -q -O - http://ident.me)
if [ -f $IPFILE ]; then
KNOWN_IP=$(cat $IPFILE)
else
KNOWN_IP=
fi

if [ "$CURRENT_IP" != "$KNOWN_IP" ]; then
echo $CURRENT_IP > $IPFILE
python /home/pi/startup_mailer.py
fi
