#!/bin/sh

DOCKER_REGISTRY=""
PROJECT="chia-docker"
TAG_NODE="compress"
#BRANCH="latest"
#BRANCH="1.7.1"
BRANCH="fc.compression"
#COMMIT="72d4a22fe773eeeb4f5d7a8b9d37cebd5200dd79"

# Build node
#docker rmi ${LOCAL_REGISTRY}/${PROJECT}:${TAG_NODE}

docker build . \
	--squash \
	--build-arg BRANCH=${BRANCH} \
	-f Dockerfile \
	-t ${DOCKER_REGISTRY}/${PROJECT}:${TAG_NODE} \
	2>&1 | tee build-node.log
	# --build-arg COMMIT="72d4a22fe773eeeb4f5d7a8b9d37cebd5200dd79" \

docker push ${DOCKER_REGISTRY}/${PROJECT}:${TAG_NODE}
