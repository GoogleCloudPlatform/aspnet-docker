#! /usr/bin/env bash

# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.

# This script will build the images for the given runtime and tag them using the
# version numbers found in the ./versions directory.
#   $1, the Docker repository to use, defaults to gcr.io/$PROJECT_ID

# Exit on error or undefined variable
set -eu

readonly workspace=$(dirname $0)/..
source ${workspace}/tools/common.inc

readonly repo=$(get_docker_namespace "${1:-}")

# Set the TAG environment to the current timestamp, it will be used to create
# the image names.
if [ -z "${TAG:-}" ]; then
    export readonly TAG=$(date +"%Y-%m-%d_%H_%M")
fi

# build all of the images.
${workspace}/tools/submit_build.sh ${workspace}/runtimes/cloudbuild.yaml ${repo}

# Tag major versions.
gcloud container images add-tag ${repo}/aspnetcore:1.0-${TAG} ${repo}/aspnetcore:1.0 --quiet
gcloud container images add-tag ${repo}/aspnetcore:1.1-${TAG} ${repo}/aspnetcore:1.1 --quiet
gcloud container images add-tag ${repo}/aspnetcore:2.0-${TAG} ${repo}/aspnetcore:2.0 --quiet
gcloud container images add-tag ${repo}/aspnetcore:2.1-${TAG} ${repo}/aspnetcore:2.1 --quiet
gcloud container images add-tag ${repo}/aspnetcore:2.2-${TAG} ${repo}/aspnetcore:2.2 --quiet

# Tag minor versions.
gcloud container images add-tag ${repo}/aspnetcore:1.0-${TAG} ${repo}/aspnetcore:1.0.16 --quiet
gcloud container images add-tag ${repo}/aspnetcore:1.1-${TAG} ${repo}/aspnetcore:1.1.13 --quiet
gcloud container images add-tag ${repo}/aspnetcore:2.0-${TAG} ${repo}/aspnetcore:2.0.9 --quiet
gcloud container images add-tag ${repo}/aspnetcore:2.1-${TAG} ${repo}/aspnetcore:2.1.15 --quiet
gcloud container images add-tag ${repo}/aspnetcore:2.2-${TAG} ${repo}/aspnetcore:2.2.6 --quiet
