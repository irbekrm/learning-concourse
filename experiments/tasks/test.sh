#!/bin/sh

set -x

vault_auth="\"role_id\":\"${ROLE_ID}\",\"secret_id\":\"${SECRET_ID}\""

result=$(curl \
  --request POST \
  --data "{${vault_auth}}" \
  "https://${VAULT_URL}/v1/auth/approle/login")

echo $result