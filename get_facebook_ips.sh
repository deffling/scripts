#!/bin/sh
# 
# Retrieves Facebook IP via WhoIs and output a comma delimited list of IPv4 addresses
# Created by: Ivan (https://github.com/deffling)

whois -h whois.radb.net '!gAS32934' | sed -r 's/([0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9]{1,2}/&\,/g' | sed 's/, /,/g'
