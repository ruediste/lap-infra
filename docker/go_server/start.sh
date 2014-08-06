#!/bin/bash

chown go: /var/lib/go-server
chown go: /var/log/go-server
chown go: /etc/go

if [ ! -f /etc/go/log4j.properties ]; then
    cp -R /etc/go-template/ /etc/go/
fi

service go-server start
tail -f /var/log/go-server/*