#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Usage docker run environment <repository URL> <env dir>"
fi

if [ ! -d "/git/.git" ]; then  
  echo "Cloning repository $1"
  git clone "$1" /git
fi

echo "Updating repository from $1 and branch $2"
cd /git
git remote set-url origin "$1"
git fetch
git reset --hard
git clean -f
git checkout "origin/master"

echo "Copying environment directory $2"
rm -rf /env
mv "/git/$2" /env/

echo "Success"

