#!/bin/bash

# push all container images
for dir in `find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n`
do
  sudo docker push localhost:5000/infra_$dir
done
