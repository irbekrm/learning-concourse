#!/bin/bash

set -eux

# Deploy Bosh with Credhub and UAA
start-bosh \
  -o /usr/local/bosh-deployment/uaa.yml \
  -o /usr/local/bosh-deployment/credhub.yml

source /tmp/local-bosh/director/env

# Install credhub CLI
tar xvzf credhub_cli/credhub-linux-*
mv credhub /usr/local/bin
# Install fly CLI
tar xvzf fly_cli/fly-*
mv fly /usr/local/bin/fly

# Set a test value in CredHub
bosh_ip="$(bosh int --path=/environments/alias=docker-director/url ~/.bosh/config)"
credhub_client="credhub-admin"
credhub_secret="$(bosh int /tmp/local-bosh/director/creds.yml --path=/credhub_admin_client_secret)"
credhub_server="https://${bosh_ip}:8844"
secret_path="/foo/bar"

credhub api "${credhub_server}" --skip-tls-validation

credhub login \
  --client-name="${credhub_client}" \
  --client-secret="${credhub_secret}" \
  --skip-tls-validation

credhub set -n "${secret_path}" -t value -v test_value

### DEPLOY CONCOURSE ###
# Upload xenial stemcell
bosh upload-stemcell xenial_stemcell/stemcell.tgz
bosh stemcells

# Upload releases
bosh upload-release postgres_bosh_release/release.tgz
bosh upload-release concourse_bosh_release/release.tgz
bosh upload-release bpm_bosh_release/release.tgz
bosh releases
# Get the static IP from cloud config
static_ip="$(bosh int --path=/networks/name=default/subnets/0/static/0 <(bosh cloud-config))"

# Deploy a Concourse
bosh deploy \
  -d concourse \
  git_repo/experiments/files/concourse.yml \
  --var=web_ip="${static_ip}" \
  --vars-store=concourse_vars.yml \
  --non-interactive

sleep 10

fly --target=test login \
  --concourse-url="http://${static_ip}:8080" \
  --username=test \
  --password=test

### SET A TEST PIPELINE ###
fly -t test set-pipeline \
  --pipeline=test_pipeline \
  --config=git_repo/experiments/files/test_pipeline.yml \
  --var=credhub_server="${credhub_server}" \
  --var=client_name="${credhub_client}" \
  --var=client_secret="${credhub_secret}" \
  --var=secret_path="${secret_path}" \
  --var=credhub_resource_tag="0.0.0-alpha.13" \
  --check-creds \
  --non-interactive

fly -t test unpause-pipeline \
  --pipeline=test_pipeline

fly -t test trigger-job \
  --job=test_pipeline/test \
  --watch

status="$(fly -t test builds --job=test_pipeline/test --json | jq -r '.[0].status')"

if [ "$status" != "succeeded" ]; then
  echo "Test pipeline failed with status ${status}"
  exit 1
fi