#!/bin/bash -x

sudo docker run -d --volumes-from infra_environment \
  --name infra_redmine_mysql -v /data/redmine/db:/var/lib/mysql localhost:5000/infra_mysql
sudo docker run -d --volumes-from infra_environment \
  --name infra_redmine --link infra_redmine_mysql:mysql \
  -v /data/redmine/files:/redmine/files \
  -e "DB_USER=redmine" -e "DB_PASS=password"  -e "DB_NAME=redmine_production" \
  -p 8080:80 \
  localhost:5000/infra_redmine
