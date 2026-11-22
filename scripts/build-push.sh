#!/bin/bash
set -e

REGION="ca-central-1"
PROFILE="tickerops"
REGISTRY="921499350264.dkr.ecr.ca-central-1.amazonaws.com"
REPO="tickerops-dev-ecr-repo"

TAG=$(git log -1 --format=%h -- app/)

docker build -t $REGISTRY/$REPO:$TAG app/

aws ecr get-login-password --region $REGION --profile $PROFILE | docker login --username AWS --password-stdin $REGISTRY

docker push $REGISTRY/$REPO:$TAG