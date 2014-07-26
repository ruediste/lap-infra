#!/bin/bash

# replace the ip in the dns db
su bind sed 's/%PRIMARY_IP%/$1/g' /etc/bin/db.internal.template > /etc/bin/db.internal

# run named under user bind and in foreground, logging to stderr
/usr/sbin/named -u bind -g -c /etc/bind/named.conf