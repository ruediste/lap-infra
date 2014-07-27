#!/bin/bash

cp ../admin_rsa.pub gitolite/

for dir in ubuntu environment dns gitolite mysql
do
  sudo docker build -t localhost:5000/infra_$dir $@ $dir
done
