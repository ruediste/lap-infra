#!/bin/bash

cp ../admin_rsa.pub gitolite/

for dir in ubuntu environment registry dns gitolite mysql redmine java go_server
do
  sudo docker build -t localhost:5000/infra_$dir $@ $dir
done
