#!/bin/bash
set -e
set -x

TAG=$TRAVIS_TAG
BRANCH=$TRAVIS_BRANCH
PR=$TRAVIS_PULL_REQUEST

echo $TAG
echo $BRANCH
echo $PR

if [ -z $TAG ]
then
    echo "No tags, tagging as: latest"
    TAG="latest"
fi

# if this is on the develop branch and this is not a PR, deploy it
if [ $BRANCH = "develop" -a $PR = "false" ]
then
    $(aws ecr get-login --region=${AWS_REGION} >/dev/null)
    docker tag -f rapidpro_rapidpro:latest ${DOCKER_IMAGE_REPO}/rapidpro:$TAG
    docker push ${DOCKER_IMAGE_REPO}/rapidpro:$TAG

    fab stage preparedeploy

    # we never want our elastic beanstalk to use tag "latest" so if this is an
    # un-tagged build, use the commit hash
    if [ $TAG = "latest" ]
    then
        TAG=$TRAVIS_COMMIT
    fi
    eb deploy -l $TAG
fi
