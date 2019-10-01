#!/bin/bash

set -euo pipefail
set -x

fly -t conc login -c "${CONCOURSE_URL}" -u "${CONCOURSE_USER}" -p "${CONCOURSE_PASSWORD}"

fly -t conc set-pipeline -p "${PIPELINE_NAME}" -c learning-concourse/experiments/tasks/setpipe.yaml