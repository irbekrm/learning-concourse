#!/bin/bash

set -eox

source /docker-lib.sh

start_docker

cd git_repo/experiments/files
docker-compose up -d

credhub login -s https://localhost:9000 -u credhub -p password --skip-tls-validation
credhub set - n /concourse/main/foo -t value -v bar
credhub get -n /concourse/main/foo

# Cleanup
docker volume rm "$(docker volume ls -q)"