#!/bin/bash
set -e

function _recreate() {
    directory="${1}"
    rm -fr "${directory}"
    mkdir -p "${directory}"
}

TAG="${TRAVIS_TAG}"
BRANCH="${TRAVIS_BRANCH}"
PR="${TRAVIS_PULL_REQUEST}"

if [ -z "${TAG}" ]; then
    echo "No tags, tagging as: ${TRAVIS_COMMIT}"
    TAG="${TRAVIS_COMMIT}"
fi

export TAG

if [[ "${PR}" == "false" ]]; then
    if [[ "${BRANCH}" == "develop" ]]; then
        BEANSTALK_ENV="${PROJECT_NAME}-dev"
    else
        echo "no env found for the deployment"
        exit 0
    fi
    export BEANSTALK_ENV
fi

echo "pushing docker image"
$(aws ecr get-login --region=${AWS_REGION})
docker tag "${PROJECT_NAME}_${PROJECT_NAME}:latest" "${DOCKER_IMAGE_REPO}/${PROJECT_NAME}:$TAG"
docker tag "${PROJECT_NAME}_${PROJECT_NAME}:latest" "${DOCKER_IMAGE_REPO}/${PROJECT_NAME}:latest"
docker push "${DOCKER_IMAGE_REPO}/${PROJECT_NAME}:${TAG}"
docker push "${DOCKER_IMAGE_REPO}/${PROJECT_NAME}:latest"

echo "preparing deployment config"
tmp_dir="tmp"
_recreate "${tmp_dir}"

git clone https://${GH_USER}:${GH_TOKEN}@github.com/eHealthAfrica/beanstalk-deploy .ebextensions

envsubst < conf/Dockerrun.aws.json.tmpl > ${tmp_dir}/Dockerrun.aws.json
cp conf/ebextensions/* .ebextensions

zip_file="${tmp_dir}/deploy.zip"
zip -r "${zip_file}" .ebextensions/ -x '*.git*'
zip -j "${zip_file}" "${tmp_dir}/Dockerrun.aws.json"
zip -j "${zip_file}" conf/nginx.conf

echo "deploying to beanstalk"
eb deploy "${BEANSTALK_ENV}" -l "${TAG}"
