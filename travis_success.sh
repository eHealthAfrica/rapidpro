#!/bin/bash
set -e

TAG=$(git tag | sort -r | tail -1)
BRANCH=$(git branch | grep "^*" | cut -d" " -f2)

if [ -z "$TAG" ]; then
    echo "No tags, aborting"
    exit -1
else
    if [ "$BRANCH" -eq "feature/nathan/dockerize"]; then
        aws ecr get-login --region=us-east-1 | bash
        docker tag rapidpro_rapidpro:latest 387526361725.dkr.ecr.us-east-1.amazonaws.com/rapidpro:$TAG
        docker push 387526361725.dkr.ecr.us-east-1.amazonaws.com/rapidpro:$TAG
    fi
fi
