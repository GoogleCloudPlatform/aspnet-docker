#!/bin/bash
source "$KOKORO_GFILE_DIR/common.sh"

cd github/aspnetcore-docker
./tools/submit_build.sh ./builder/cloudbuild.yaml ${DOCKER_NAMESPACE}
