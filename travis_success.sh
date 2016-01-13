#1/bin/bash
set -e

TAG=$(git tag | sort -r | tail -1)

if [ -z "$TAG" ]; then
    echo "No tags, aborting"
    exit -1
else
    echo "yes"
    exit 0
    aws ecr get-login --region=us-east-1 | bash
    docker tag rapidpro_rapidpro:latest 387526361725.dkr.ecr.us-east-1.amazonaws.com/rapidpro:$TAG
    docker push 387526361725.dkr.ecr.us-east-1.amazonaws.com/rapidpro:$TAG
fi
