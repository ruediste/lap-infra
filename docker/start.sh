#!/bin/bash -x

if [ -z "$LAP_ENVIRONMENT" ]; then
    echo "Need to set LAP_ENVIRONMENT"
    exit 1
fi  

sudo docker run --name infra_environment -v /data/lap-infra/env/$LAP_ENVIRONMENT:/env localhost:5000/infra_environment echo foo

sudo docker run -d --volumes-from infra_environment --name infra_gitolite -v /data/gitolite:/var/lib/gitolite -p 2200:22 localhost:5000/infra_gitolite
sudo docker run -d --volumes-from infra_environment --name infra_registry -v /data/registry:/data -p 5000:5000 -e SETTINGS_FLAVOR=local -e STORAGE_PATH=/data localhost:5000/infra_registry
sudo docker run -d --volumes-from infra_environment --name infra_dns -p `cat /etc/primaryip`:53:53/udp -p `cat /etc/primaryip`:53:53 localhost:5000/infra_dns /run.sh `cat /etc/primaryip`
./doStartRedmine.sh 
sudo docker run -d --volumes-from infra_environment --name infra_go_server -p 8153:8153 localhost:5000/infra_go_server /bin/bash -c "service go-server start; tail -f /var/log/go-server/*"