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

# This script will build the ASP.NET Core image.
#   $1, the image to build.
#   $2, repository for the resulting image.

# Exit on error or undefined variable
set -eu

if [ -z "${1:-}" ]; then
    echo "Must specify the image directory."
    exit 1
fi

if [ -z "${2:-}" ]; then
    echo "Must specify the name of the repo."
    exit 1
fi

readonly workspace=$(dirname $0)/..
readonly image=$(basename $1)
readonly image_name=$(echo -n ${image} | cut -f 1 -d -)

# Process the template.
if [ -z "${TAG:-}" ]; then
  TAG=$(date +"%Y-%m-%d_%H_%M")
fi

if [[ ${image} == *-* ]]; then
    readonly image_version=$(echo -n ${image} | cut -f 2 -d -)-${TAG}
else
    readonly image_version=${TAG}
fi

readonly image_tag=$2/${image_name}:${image_version}
echo "Building ${image_tag}"

# If the directory specify a build file, use that instead.
if [ -f $1/cloudbuild.yaml ]; then
    readonly cloudbuild_path="$1/cloudbuild.yaml"
else
    readonly cloudbuild_path="${workspace}/tools/cloudbuild.yaml"
fi
echo "Building with ${cloudbuild_path}"

# Start the build.
gcloud beta container builds submit "$1" \
    --config="${cloudbuild_path}" \
    --substitutions _OUTPUT_IMAGE=${image_tag}
