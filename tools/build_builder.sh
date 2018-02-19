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

# This script will build the builder image.
#   $1, the Docker repository to use, defaults to gcr.io/$PROJECT_ID

# Exit on error or undefined variable
set -eu

readonly workspace=$(dirname $0)/..
source ${workspace}/tools/common.inc
readonly tools=${workspace}/tools

readonly repo=$(get_docker_namespace "${1:-}")

# Set the TAG environment to the current timestamp, it will be used to create
# the image names.
if [ -z "${TAG:-}" ]; then
    export readonly TAG=$(date +"%Y-%m-%d_%H_%M")
fi

# Build and tag the builder.
${tools}/submit_build.sh ${workspace}/builder/cloudbuild.yaml ${repo}

readonly builder_datestamp_image=${repo}/aspnetcorebuild:${TAG}
readonly builder_versioned_image=${repo}/aspnetcorebuild:latest

gcloud container images add-tag ${builder_datestamp_image} ${builder_versioned_image} --quiet
