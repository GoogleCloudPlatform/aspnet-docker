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

# If no repo is given get it from the ambient project.
if [ -z "${1:-}" ]; then
    readonly project_id=$(gcloud config list core/project --format="csv[no-heading](core)" | cut -f 2 -d '=')
    readonly repo=gcr.io/${project_id}
    echo "Warning: Using repo ${repo} from ambient project."
else
    readonly repo=$1
fi

# Set the TAG environment to the current timestamp, it will be used to create
# the image names.
if [ -z "${TAG:-}" ]; then
    export readonly TAG=$(date +"%Y-%m-%d_%H_%M")
fi

# build all of the images.
${workspace}/tools/submit_build.sh ${workspace}/runtimes/cloudbuild.yaml ${repo}

# The list of supported versions.
readonly runtime_versions=(
    "1.0.9"
    "1.1.6"
    "2.0.5"
)

# Tag all of the images.
for ver in ${runtime_versions[@]}; do
    datestamp_image=${repo}/aspnetcore:${ver}-${TAG}
    versioned_image=${repo}/aspnetcore:${ver}
    echo "Tagging ${datestamp_image} with ${versioned_image}"
    gcloud container images add-tag ${datestamp_image} ${versioned_image} --quiet
done