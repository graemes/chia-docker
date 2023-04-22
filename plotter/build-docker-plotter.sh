#!/bin/sh

#DOCKER_REGISTRY="cryptohub"
DOCKER_REGISTRY="graemes"
LOCAL_REGISTRY="registry.graemes.cloud/graemes"
PROJECT="chia-docker"
TAG="plotter"
BRANCH="1.1.6"

#docker pull regproxy.graemes.cloud/dockerhub/library/debian:10

docker rmi ${LOCAL_REGISTRY}/${PROJECT}:${TAG}

docker build . \
	--squash \
	--build-arg BRANCH=${BRANCH} \
	-f Dockerfile.${TAG} \
	-t ${LOCAL_REGISTRY}/${PROJECT}:${TAG}

#     -t ${DOCKER_REGISTRY}/${PROJECT}:${TAG} \

docker push ${LOCAL_REGISTRY}/${PROJECT}:${TAG}
#docker push ${DOCKER_REGISTRY}/${PROJECT}:${TAG}
