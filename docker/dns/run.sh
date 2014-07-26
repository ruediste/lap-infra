#!/bin/bash

# replace the ip in the dns db
sudo -u bind bash -c "sed 's/%PRIMARY_IP%/$1/g' /etc/bind/db.internal.template > /etc/bind/db.internal"

# run named under user bind and in foreground, logging to stderr
/usr/sbin/named -u bind -g -c /etc/bind/named.conf