#!/bin/bash
set -e

TAG=$(git log -1 --format=%h -- app/)

# -chdir, which means "run as if you were in this folder
terraform -chdir=envs/dev apply -target=module.ecr -var="image_tag=$TAG"

./scripts/build-push.sh

terraform -chdir=envs/dev apply -var="image_tag=$TAG"