#!/bin/bash
set -e

TAG=$(git describe --tags $(git rev-parse HEAD))
BRANCH=$(git branch | grep "^*" | cut -d" " -f2)

echo $TAG
echo $BRANCH

if [ -z $TAG ]
then
    echo "No tags, tagging as: latest"
    TAG="latest"
fi

if [ $BRANCH = "feature/nathan/dockerize" ]
then
    aws ecr get-login --region=us-east-1 | bash
    docker tag rapidpro_rapidpro:latest 387526361725.dkr.ecr.us-east-1.amazonaws.com/rapidpro:$TAG
    docker push 387526361725.dkr.ecr.us-east-1.amazonaws.com/rapidpro:$TAG
fi
