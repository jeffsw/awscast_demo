#!/bin/bash
apt-get update
apt-get -y install \
  apache2 \
  bind9 \

mkdir /etc/bind/zones

# create zone file
# SHELL ESCAPE THE CONTENTS OF THE FILE OR IT WILL BREAK
cat << ZONE > /etc/bind/zones/test
; zone file for test.
\$TTL	600
@	IN	SOA	aws-cast-test.jeffsw.com. jeffsw6.gmail.com. (
			      1		; Serial
			    300 	; Refresh
			    300 	; Retry
			    600 	; Expire
			    300	)	; Negative Cache TTL
@	IN	NS	aws-cast-test.jeffsw.com.

hello-world		IN	A	127.0.0.50
ZONE

# overwrite named.conf.local config file
cat << CONF > /etc/bind/named.conf.local
zone "test" { type master; file "/etc/bind/zones/test"; };
CONF

systemctl reload bind9.service
