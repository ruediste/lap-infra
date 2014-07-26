#!/bin/bash

cp ../admin_rsa.pub gitolite/

for dir in ubuntu `find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n'`
do
  sudo docker build -t localhost:5000/infra_$dir $@ $dir
done
