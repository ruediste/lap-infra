#!/bin/bash
if [ -z "$LAP_ENVIRONMENT" ]; then
    echo "Need to set LAP_ENVIRONMENT"
    exit 1
fi  
sudo docker run -d --name infra_gitolite -v /data/gitolite:/var/lib/gitolite -p 2200:22 localhost:5000/gitolite
sudo docker run -d --name infra_registry -p 5000:5000 -v /data/registry:/data -e SETTINGS_FLAVOR=local -e STORAGE_PATH=/data localhost:5000/registry

sudo docker run --name infra_environment --link infra_gitolite:git environment /run.sh git@git:environment.git $LAP_ENVIRONMENT
