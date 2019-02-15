#!/bin/bash

source "$KOKORO_GFILE_DIR/common.sh"

cd aspnetcore-docker

# Build and tag the runtimes.
tools/build_runtimes.sh ${DOCKER_NAMESPACE}

# Build and tag the builder.
export readonly TAG=$(date +"%Y-%m-%d_%H_%M")
tools/submit_build.sh builder/cloudbuild.yaml ${DOCKER_NAMESPACE}
gcloud container images add-tag \
  ${DOCKER_NAMESPACE}/aspnetcorebuild:${TAG} \
  ${DOCKER_NAMESPACE}/aspnetcorebuild:latest
