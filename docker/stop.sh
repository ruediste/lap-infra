#!/bin/bash

# stop all images containing "infra_" in the name

sudo docker ps -a | tail -n +2 | cut -c 1-13,142- | grep "infra_" | cut -c 1-13 | xargs sudo docker rm -f 