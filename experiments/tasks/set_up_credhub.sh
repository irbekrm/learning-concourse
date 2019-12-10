#!/bin/bash

set -eox

source /docker-lib.sh

start_docker

docker load -i credhub_image
docker tag "$(cat credhub_image/image-id)" "$(cat credhub_image/repository):$(cat credhub_image/tag)"

docker load -i uaa_image
docker tag "$(cat uaa_image/image-id)" "$(cat uaa_image/repository):$(cat uaa_image/tag)"

# Check that images have been loaded
docker images

cd git_repo/experiments/files
docker-compose -f docker-compose.yml -d

credhub login -s https://localhost:9000 -u credhub -p password --skip-tls-validation
credhub set - n /concourse/main/foo -t value -v bar
credhub get -n /concourse/main/foo

# Cleanup
docker volume rm "$(docker volume ls -q)"